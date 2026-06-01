from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import MinValueValidator, MaxValueValidator, RegexValidator
from django.utils import timezone

class User(AbstractUser):
    """Custom User model with RMU email verification"""
    email = models.EmailField(
        unique=True,
        validators=[RegexValidator(
            regex=r'^[\w\.-]+@st\.rmu\.edu\.gh$',
            message='Must use @st.rmu.edu.gh email address'
        )]
    )
    profile_pic = models.URLField(max_length=500, blank=True, null=True)
    skills = models.TextField(blank=True, null=True, help_text="e.g., Python, Graphic Design, Tutoring")
    rating = models.DecimalField(max_digits=2, decimal_places=1, default=0.0, validators=[MinValueValidator(0), MaxValueValidator(5)])
    is_active = models.BooleanField(default=True)
    is_admin = models.BooleanField(default=False)
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    joined_date = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"{self.username} ({self.email})"
    
    class Meta:
        ordering = ['-joined_date']

class Product(models.Model):
    """Product or Service listing"""
    CATEGORY_CHOICES = [
        ('textbook', 'Textbook'),
        ('electronics', 'Electronics'),
        ('service', 'Service'),
        ('tutoring', 'Tutoring'),
        ('design', 'Design'),
        ('other', 'Other'),
    ]
    
    CONDITION_CHOICES = [
        ('new', 'New'),
        ('like-new', 'Like New'),
        ('good', 'Good'),
        ('fair', 'Fair'),
        ('poor', 'Poor'),
    ]
    
    DELIVERY_CHOICES = [
        ('pickup', 'Pickup'),
        ('digital', 'Digital Delivery'),
        ('meetup', 'Campus Meetup'),
    ]
    
    STATUS_CHOICES = [
        ('available', 'Available'),
        ('sold', 'Sold'),
        ('hidden', 'Hidden'),
        ('flagged', 'Flagged'),
    ]
    
    seller = models.ForeignKey(User, on_delete=models.CASCADE, related_name='products')
    title = models.CharField(max_length=255)
    description = models.TextField()
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    condition = models.CharField(max_length=20, choices=CONDITION_CHOICES, blank=True, null=True)
    price = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    delivery_method = models.CharField(max_length=20, choices=DELIVERY_CHOICES, default='pickup')
    image_urls = models.JSONField(default=list, blank=True, help_text="List of image URLs")
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='available')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.title} - {self.seller.username}"
    
    class Meta:
        ordering = ['-created_at']

class Message(models.Model):
    """In-app messaging between users"""
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='received_messages')
    product = models.ForeignKey(Product, on_delete=models.SET_NULL, null=True, blank=True, related_name='messages')
    message_text = models.TextField()
    is_read = models.BooleanField(default=False)
    sent_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"From {self.sender.username} to {self.receiver.username}"
    
    class Meta:
        ordering = ['sent_at']

class Transaction(models.Model):
    """Agreed deals between buyer and seller"""
    STATUS_CHOICES = [
        ('negotiating', 'Negotiating'),
        ('agreed', 'Agreed'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ]
    
    product = models.OneToOneField(Product, on_delete=models.CASCADE, related_name='transaction')
    buyer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='purchases')
    seller = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sales')
    agreed_price = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='negotiating')
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"Transaction #{self.id}: {self.product.title}"
    
    def save(self, *args, **kwargs):
        if self.status == 'completed' and not self.completed_at:
            self.completed_at = timezone.now()
        super().save(*args, **kwargs)


class Payment(models.Model):
    """Track Paystack payment transactions"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('success', 'Success'),
        ('failed', 'Failed'),
        ('cancelled', 'Cancelled'),
    ]
    
    transaction = models.OneToOneField(Transaction, on_delete=models.CASCADE, related_name='payment')
    paystack_reference = models.CharField(max_length=255, unique=True, null=True, blank=True)
    paystack_access_code = models.CharField(max_length=255, null=True, blank=True)
    paystack_authorization_url = models.URLField(null=True, blank=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2, validators=[MinValueValidator(0)])
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    payment_method = models.CharField(max_length=50, default='paystack')
    created_at = models.DateTimeField(auto_now_add=True)
    verified_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"Payment for {self.transaction.product.title} - {self.status}"
    
    class Meta:
        ordering = ['-created_at']


class Report(models.Model):
    """User reports for inappropriate content"""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('resolved', 'Resolved'),
        ('dismissed', 'Dismissed'),
    ]
    
    reporter = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reports')
    product = models.ForeignKey(Product, on_delete=models.CASCADE, null=True, blank=True, related_name='reports')
    message = models.ForeignKey(Message, on_delete=models.CASCADE, null=True, blank=True, related_name='reports')
    reason = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    resolved_at = models.DateTimeField(null=True, blank=True)
    resolved_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='resolved_reports')
    
    def __str__(self):
        return f"Report #{self.id} by {self.reporter.username}"
    
    class Meta:
        ordering = ['-created_at']

class AdminLog(models.Model):
    """Track admin actions for accountability"""
    admin = models.ForeignKey(User, on_delete=models.CASCADE, related_name='admin_logs')
    action = models.CharField(max_length=255)
    target_type = models.CharField(max_length=50, choices=[
        ('product', 'Product'),
        ('user', 'User'),
        ('message', 'Message'),
    ])
    target_id = models.IntegerField()
    details = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.admin.username}: {self.action} at {self.created_at}"
    
    class Meta:
        ordering = ['-created_at']