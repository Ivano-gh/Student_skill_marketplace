from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, generics, permissions
from rest_framework.permissions import AllowAny
from rest_framework.renderers import JSONRenderer
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth import authenticate
from django.db import IntegrityError
from django.db.models import Q
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.conf import settings
from django.utils import timezone
from .models import User, Product, Message, Transaction, Payment
from .serializers import (
    SignupSerializer,
    LoginSerializer,
    UserSerializer,
    ProductSerializer,
    MessageSerializer,
    TransactionSerializer,
    PaymentSerializer,
)
import requests
import json

@method_decorator(csrf_exempt, name='dispatch')
class SignupView(APIView):
    permission_classes = [AllowAny]
    renderer_classes = [JSONRenderer]

    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        if serializer.is_valid():
            try:
                user = serializer.create(serializer.validated_data)
            except IntegrityError:
                return Response(
                    {"error": "Username or email already exists."},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            refresh = RefreshToken.for_user(user)
            return Response({
                "message": "User created successfully",
                "user": UserSerializer(user).data,
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@method_decorator(csrf_exempt, name='dispatch')
class LoginView(APIView):
    permission_classes = [AllowAny]
    renderer_classes = [JSONRenderer]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['username']  # assuming username is email
            password = serializer.validated_data['password']
            try:
                user = User.objects.get(email=email)
                if user.check_password(password):
                    refresh = RefreshToken.for_user(user)
                    return Response({
                        "message": "Login successful",
                        "user": UserSerializer(user).data,
                        "refresh": str(refresh),
                        "access": str(refresh.access_token),
                    })
                else:
                    return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)
            except User.DoesNotExist:
                return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@method_decorator(csrf_exempt, name='dispatch')
class LogoutView(APIView):
    permission_classes = [AllowAny]
    renderer_classes = [JSONRenderer]

    def post(self, request):
        try:
            refresh_token = request.data["refresh"]
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({"message": "Logged out successfully"})
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class ProductListCreateView(generics.ListCreateAPIView):
    queryset = Product.objects.filter(status='available').order_by('-created_at')
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def perform_create(self, serializer):
        serializer.save(seller=self.request.user)


class ProductDetailView(generics.RetrieveUpdateDestroyAPIView):
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return Product.objects.all()

    def get_object(self):
        obj = super().get_object()
        # Allow anyone to retrieve, but only seller can update/delete
        if self.request.method not in permissions.SAFE_METHODS:
            if obj.seller != self.request.user:
                from rest_framework.exceptions import PermissionDenied
                raise PermissionDenied("You can only modify your own products")
        return obj

    def perform_update(self, serializer):
        serializer.save(seller=self.request.user)

    def perform_destroy(self, instance):
        if instance.seller != self.request.user:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("You can only delete your own products")
        instance.delete()


class UserProductsView(generics.ListAPIView):
    """Get all products (published and unpublished) for the authenticated user"""
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Product.objects.filter(seller=self.request.user).order_by('-created_at')


class ProductStatusView(APIView):
    """Update product status (available, sold, hidden, flagged)"""
    permission_classes = [permissions.IsAuthenticated]
    renderer_classes = [JSONRenderer]

    def patch(self, request, pk):
        try:
            product = Product.objects.get(id=pk, seller=request.user)
        except Product.DoesNotExist:
            return Response(
                {"error": "Product not found or you don't have permission to modify it"},
                status=status.HTTP_404_NOT_FOUND,
            )

        new_status = request.data.get('status')
        valid_statuses = [choice[0] for choice in Product.STATUS_CHOICES]
        
        if not new_status or new_status not in valid_statuses:
            return Response(
                {"error": f"Invalid status. Must be one of: {', '.join(valid_statuses)}"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        product.status = new_status
        product.save()

        return Response({
            "message": f"Product status updated to '{new_status}'",
            "product": ProductSerializer(product).data,
        }, status=status.HTTP_200_OK)


class MessageListCreateView(generics.ListCreateAPIView):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Message.objects.filter(Q(sender=user) | Q(receiver=user)).order_by('-sent_at')

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)


class TransactionListCreateView(generics.ListCreateAPIView):
    serializer_class = TransactionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return Transaction.objects.filter(Q(buyer=user) | Q(seller=user)).order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save()


@method_decorator(csrf_exempt, name='dispatch')
class PaymentInitializeView(APIView):
    """Initialize Paystack payment for a transaction"""
    permission_classes = [permissions.IsAuthenticated]
    renderer_classes = [JSONRenderer]

    def post(self, request):
        transaction_id = request.data.get('transaction_id')
        if not transaction_id:
            return Response(
                {"error": "transaction_id is required"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            transaction = Transaction.objects.get(id=transaction_id, buyer=request.user)
        except Transaction.DoesNotExist:
            return Response(
                {"error": "Transaction not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Create or update payment
        payment, created = Payment.objects.get_or_create(
            transaction=transaction,
            defaults={'amount': transaction.agreed_price}
        )

        # Initialize with Paystack
        paystack_key = settings.PAYSTACK_SECRET_KEY
        if not paystack_key:
            return Response(
                {"error": "Paystack not configured"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        payload = {
            "email": transaction.buyer.email,
            "amount": int(float(transaction.agreed_price) * 100),  # Convert to kobo
            "reference": f"TXN-{transaction.id}-{payment.id}",
            "metadata": {
                "transaction_id": transaction.id,
                "payment_id": payment.id,
                "product": transaction.product.title,
            }
        }

        headers = {
            "Authorization": f"Bearer {paystack_key}",
            "Content-Type": "application/json",
        }

        try:
            response = requests.post(
                "https://api.paystack.co/transaction/initialize",
                json=payload,
                headers=headers,
                timeout=10,
            )
            
            if response.status_code == 200:
                data = response.json()
                payment.paystack_reference = data['data']['reference']
                payment.paystack_access_code = data['data']['access_code']
                payment.paystack_authorization_url = data['data']['authorization_url']
                payment.save()

                return Response({
                    "authorization_url": data['data']['authorization_url'],
                    "access_code": data['data']['access_code'],
                    "reference": data['data']['reference'],
                }, status=status.HTTP_200_OK)
            else:
                return Response(
                    {"error": "Failed to initialize payment with Paystack"},
                    status=status.HTTP_400_BAD_REQUEST,
                )
        except requests.exceptions.RequestException as e:
            return Response(
                {"error": f"Payment service error: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


@method_decorator(csrf_exempt, name='dispatch')
class PaymentVerifyView(APIView):
    """Verify Paystack payment and mark transaction as completed"""
    permission_classes = [permissions.IsAuthenticated]
    renderer_classes = [JSONRenderer]

    def post(self, request):
        reference = request.data.get('reference')
        if not reference:
            return Response(
                {"error": "reference is required"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            payment = Payment.objects.get(paystack_reference=reference)
        except Payment.DoesNotExist:
            return Response(
                {"error": "Payment not found"},
                status=status.HTTP_404_NOT_FOUND,
            )

        # Verify with Paystack
        paystack_key = settings.PAYSTACK_SECRET_KEY
        if not paystack_key:
            return Response(
                {"error": "Paystack not configured"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )

        headers = {
            "Authorization": f"Bearer {paystack_key}",
        }

        try:
            response = requests.get(
                f"https://api.paystack.co/transaction/verify/{reference}",
                headers=headers,
                timeout=10,
            )

            if response.status_code == 200:
                data = response.json()
                if data['data']['status'] == 'success':
                    # Mark payment and transaction as completed
                    payment.status = 'success'
                    payment.verified_at = timezone.now()
                    payment.save()

                    transaction = payment.transaction
                    transaction.status = 'completed'
                    transaction.save()

                    # Product is already marked as sold when transaction was created
                    return Response({
                        "message": "Payment verified successfully",
                        "transaction_id": transaction.id,
                        "status": "completed",
                    }, status=status.HTTP_200_OK)
                else:
                    payment.status = 'failed'
                    payment.save()
                    return Response(
                        {"error": "Payment verification failed"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
            else:
                return Response(
                    {"error": "Failed to verify payment with Paystack"},
                    status=status.HTTP_400_BAD_REQUEST,
                )
        except requests.exceptions.RequestException as e:
            return Response(
                {"error": f"Payment service error: {str(e)}"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )
