from django.urls import path
from .views import (
    SignupView,
    LoginView,
    LogoutView,
    ProductListCreateView,
    ProductDetailView,
    UserProductsView,
    ProductStatusView,
    MessageListCreateView,
    TransactionListCreateView,
    PaymentInitializeView,
    PaymentVerifyView,
)
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('signup/', SignupView.as_view()),
    path('login/', LoginView.as_view()),
    path('logout/', LogoutView.as_view()),
    path('products/', ProductListCreateView.as_view()),
    path('products/<int:pk>/', ProductDetailView.as_view()),
    path('my-products/', UserProductsView.as_view()),
    path('products/<int:pk>/status/', ProductStatusView.as_view()),
    path('messages/', MessageListCreateView.as_view()),
    path('transactions/', TransactionListCreateView.as_view()),
    path('payment/initialize/', PaymentInitializeView.as_view()),
    path('payment/verify/', PaymentVerifyView.as_view()),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]