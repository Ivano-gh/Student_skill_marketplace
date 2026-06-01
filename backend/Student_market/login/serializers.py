from rest_framework import serializers
from rest_framework.validators import UniqueValidator
from .models import User, Product, Message, Transaction, Payment

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password', 'profile_pic', 'skills', 'rating', 'phone_number', 'joined_date']

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class SignupSerializer(serializers.Serializer):
    username = serializers.CharField(
        max_length=150,
        validators=[
            UniqueValidator(queryset=User.objects.all(), message="Username already exists")
        ]
    )
    email = serializers.EmailField(
        validators=[
            UniqueValidator(queryset=User.objects.all(), message="Email already registered")
        ]
    )
    password = serializers.CharField(write_only=True, min_length=8)

    def validate_username(self, value):
        value = value.strip()
        if not value:
            raise serializers.ValidationError("Username cannot be blank")
        return value

    def validate_email(self, value):
        value = value.strip().lower()
        if not value.endswith('@st.rmu.edu.gh'):
            raise serializers.ValidationError("Must use @st.rmu.edu.gh email address")
        return value

    def create(self, validated_data):
        validated_data['email'] = validated_data['email'].lower()
        return User.objects.create_user(**validated_data)

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

class ProductSerializer(serializers.ModelSerializer):
    seller_id = serializers.IntegerField(source='seller.id', read_only=True)
    seller_name = serializers.CharField(source='seller.username', read_only=True)
    seller_email = serializers.EmailField(source='seller.email', read_only=True)
    seller_level = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = [
            'id',
            'title',
            'description',
            'category',
            'condition',
            'price',
            'delivery_method',
            'image_urls',
            'status',
            'created_at',
            'updated_at',
            'seller_id',
            'seller_name',
            'seller_email',
            'seller_level',
        ]
        read_only_fields = ['status', 'created_at', 'updated_at', 'seller_id', 'seller_name', 'seller_email', 'seller_level']

    def get_seller_level(self, obj):
        return 'Verified Seller'

    def create(self, validated_data):
        seller = self.context['request'].user
        validated_data['seller'] = seller
        return super().create(validated_data)

class MessageSerializer(serializers.ModelSerializer):
    sender_id = serializers.IntegerField(source='sender.id', read_only=True)
    sender_username = serializers.CharField(source='sender.username', read_only=True)
    receiver_id = serializers.IntegerField(source='receiver.id')
    receiver_username = serializers.CharField(source='receiver.username', read_only=True)
    product_id = serializers.IntegerField(source='product.id')

    class Meta:
        model = Message
        fields = [
            'id',
            'sender_id',
            'sender_username',
            'receiver_id',
            'receiver_username',
            'product_id',
            'message_text',
            'is_read',
            'sent_at',
        ]
        read_only_fields = ['id', 'sender_id', 'sender_username', 'receiver_username', 'is_read', 'sent_at']

    def create(self, validated_data):
        validated_data['sender'] = self.context['request'].user
        return super().create(validated_data)

class TransactionSerializer(serializers.ModelSerializer):
    buyer_id = serializers.IntegerField(source='buyer.id', read_only=True)
    buyer_username = serializers.CharField(source='buyer.username', read_only=True)
    seller_id = serializers.IntegerField(source='seller.id', read_only=True)
    seller_username = serializers.CharField(source='seller.username', read_only=True)
    product_title = serializers.CharField(source='product.title', read_only=True)

    class Meta:
        model = Transaction
        fields = [
            'id',
            'product',
            'product_title',
            'buyer_id',
            'buyer_username',
            'seller_id',
            'seller_username',
            'agreed_price',
            'status',
            'created_at',
            'completed_at',
        ]
        read_only_fields = ['id', 'product_title', 'buyer_id', 'buyer_username', 'seller_id', 'seller_username', 'status', 'created_at', 'completed_at']

    def validate_product(self, value):
        if value.status != 'available':
            raise serializers.ValidationError('Product is not available for purchase.')
        return value

    def create(self, validated_data):
        product = validated_data['product']
        validated_data['buyer'] = self.context['request'].user
        validated_data['seller'] = product.seller
        transaction = super().create(validated_data)
        product.status = 'sold'
        product.save(update_fields=['status'])
        return transaction


class PaymentSerializer(serializers.ModelSerializer):
    transaction_id = serializers.IntegerField(source='transaction.id', read_only=True)
    buyer_email = serializers.CharField(source='transaction.buyer.email', read_only=True)
    product_title = serializers.CharField(source='transaction.product.title', read_only=True)
    amount = serializers.SerializerMethodField()

    class Meta:
        model = Payment
        fields = [
            'id',
            'transaction_id',
            'paystack_reference',
            'paystack_access_code',
            'paystack_authorization_url',
            'amount',
            'status',
            'payment_method',
            'created_at',
            'verified_at',
            'buyer_email',
            'product_title',
        ]
        read_only_fields = [
            'id',
            'transaction_id',
            'paystack_reference',
            'paystack_access_code',
            'paystack_authorization_url',
            'status',
            'payment_method',
            'created_at',
            'verified_at',
            'buyer_email',
            'product_title',
        ]

    def get_amount(self, obj):
        return float(obj.amount)