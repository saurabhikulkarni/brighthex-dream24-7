# Backend Implementation Examples

This file provides example code snippets for implementing the required backend APIs.

## Node.js/Express Examples

### User Schema Update

```javascript
// models/User.js
const userSchema = new Schema({
  phone: {
    type: String,
    required: true,
    unique: true,
  },
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
  },
  walletBalance: {
    type: Number,
    default: 0,
    min: 0,
  },
  wishlist: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
  }],
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('User', userSchema);
```

### 1. Login Endpoint

```javascript
// routes/auth.js
const express = require('express');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Product = require('../models/Product');

router.post('/auth/login', async (req, res) => {
  try {
    const { phone, otp, name } = req.body;

    // Verify OTP (from your OTP service)
    const isOtpValid = await verifyOTP(phone, otp);
    if (!isOtpValid) {
      return res.status(400).json({ success: false, message: 'Invalid OTP' });
    }

    // Find or create user
    let user = await User.findOne({ phone });
    if (!user) {
      user = new User({ phone, name });
      await user.save();
    } else if (user.name !== name) {
      user.name = name;
      await user.save();
    }

    // Populate wishlist with product details
    await user.populate('wishlist');

    // Generate JWT token
    const token = jwt.sign(
      { userId: user._id, phone: user.phone },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    // Return user with wallet balance
    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        phone: user.phone,
        name: user.name,
        email: user.email,
        walletBalance: user.walletBalance,
        wishlist: user.wishlist, // Array of product objects
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});
```

### 2. Get User Profile

```javascript
// Middleware for JWT verification
const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'No token' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (error) {
    res.status(401).json({ message: 'Invalid token' });
  }
};

// GET /api/users/profile
router.get('/users/profile', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId)
      .populate('wishlist')
      .select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({
      id: user._id,
      phone: user.phone,
      name: user.name,
      email: user.email,
      walletBalance: user.walletBalance,
      wishlist: user.wishlist,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

### 3. Get Wallet Balance

```javascript
// GET /api/users/wallet
router.get('/users/wallet', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId);
    res.json({
      walletBalance: user.walletBalance,
      currency: 'INR',
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

### 4. Add Money to Wallet

```javascript
// POST /api/users/wallet/add
router.post('/users/wallet/add', authMiddleware, async (req, res) => {
  try {
    const { amount, paymentId } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ message: 'Invalid amount' });
    }

    // Verify payment with Razorpay or your payment provider
    const paymentVerified = await verifyRazorpayPayment(paymentId);
    if (!paymentVerified) {
      return res.status(400).json({ message: 'Payment verification failed' });
    }

    // Update wallet
    const user = await User.findById(req.userId);
    user.walletBalance += amount;
    await user.save();

    // Log transaction
    await WalletTransaction.create({
      userId: user._id,
      type: 'credit',
      amount,
      paymentId,
      description: 'Add money to wallet',
    });

    res.json({
      success: true,
      walletBalance: user.walletBalance,
      transaction: {
        id: paymentId,
        type: 'credit',
        amount,
        timestamp: new Date().toISOString(),
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

### 5. Deduct from Wallet (Purchase)

```javascript
// POST /api/users/wallet/deduct
router.post('/users/wallet/deduct', authMiddleware, async (req, res) => {
  try {
    const { amount, orderId } = req.body;

    const user = await User.findById(req.userId);

    // Check sufficient balance
    if (user.walletBalance < amount) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient wallet balance',
        availableBalance: user.walletBalance,
      });
    }

    // Deduct amount
    user.walletBalance -= amount;
    await user.save();

    // Log transaction
    const transaction = await WalletTransaction.create({
      userId: user._id,
      type: 'debit',
      amount,
      orderId,
      description: 'Purchase order',
    });

    res.json({
      success: true,
      walletBalance: user.walletBalance,
      transaction: {
        id: transaction._id,
        type: 'debit',
        amount,
        timestamp: transaction.createdAt.toISOString(),
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

### 6. Get Wishlist

```javascript
// GET /api/users/wishlist
router.get('/users/wishlist', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId)
      .populate('wishlist');

    const wishlist = user.wishlist.map(product => ({
      id: product._id,
      title: product.title,
      price: product.price,
      image: product.image,
      category: product.category,
    }));

    res.json({ wishlist });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

### 7. Add to Wishlist

```javascript
// POST /api/users/wishlist/add
router.post('/users/wishlist/add', authMiddleware, async (req, res) => {
  try {
    const { productId } = req.body;

    // Verify product exists
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({ message: 'Product not found' });
    }

    const user = await User.findById(req.userId);

    // Check if already in wishlist
    if (user.wishlist.includes(productId)) {
      return res.status(400).json({ message: 'Already in wishlist' });
    }

    // Add to wishlist
    user.wishlist.push(productId);
    await user.save();

    res.json({
      success: true,
      message: 'Added to wishlist',
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

### 8. Remove from Wishlist

```javascript
// DELETE /api/users/wishlist/:productId
router.delete('/users/wishlist/:productId', authMiddleware, async (req, res) => {
  try {
    const { productId } = req.params;

    const user = await User.findById(req.userId);

    // Remove from wishlist
    user.wishlist = user.wishlist.filter(
      id => id.toString() !== productId
    );
    await user.save();

    res.json({
      success: true,
      message: 'Removed from wishlist',
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});
```

## Python/Django Examples

### User Model

```python
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

class UserManager(BaseUserManager):
    def create_user(self, phone, name, password=None):
        user = self.model(phone=phone, name=name)
        user.set_password(password)
        user.save(using=self._db)
        return user

class User(AbstractBaseUser):
    phone = models.CharField(max_length=15, unique=True)
    name = models.CharField(max_length=100)
    email = models.EmailField(blank=True)
    wallet_balance = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    wishlist = models.ManyToManyField('Product', related_name='wishlisted_by', blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    objects = UserManager()
    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['name']

    def __str__(self):
        return f"{self.name} ({self.phone})"
```

### Login View

```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
import jwt

@api_view(['POST'])
def login(request):
    try:
        phone = request.data.get('phone')
        otp = request.data.get('otp')
        name = request.data.get('name')

        # Verify OTP
        if not verify_otp(phone, otp):
            return Response({'success': False, 'message': 'Invalid OTP'}, status=400)

        # Get or create user
        user, created = User.objects.get_or_create(
            phone=phone,
            defaults={'name': name}
        )
        if not created and user.name != name:
            user.name = name
            user.save()

        # Generate tokens
        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)

        # Serialize wishlist products
        wishlist_products = [
            {
                'id': str(product.id),
                'title': product.title,
                'price': float(product.price),
                'image': product.image.url if product.image else '',
            }
            for product in user.wishlist.all()
        ]

        return Response({
            'success': True,
            'token': access_token,
            'user': {
                'id': str(user.id),
                'phone': user.phone,
                'name': user.name,
                'email': user.email,
                'walletBalance': float(user.wallet_balance),
                'wishlist': wishlist_products,
            }
        })
    except Exception as e:
        return Response({'success': False, 'message': str(e)}, status=500)
```

### Wallet Deduction View

```python
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.db import transaction

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def deduct_wallet(request):
    try:
        amount = float(request.data.get('amount', 0))
        order_id = request.data.get('orderId')

        user = request.user

        if user.wallet_balance < amount:
            return Response({
                'success': False,
                'message': 'Insufficient wallet balance',
                'availableBalance': float(user.wallet_balance)
            }, status=400)

        # Use transaction for safety
        with transaction.atomic():
            user.wallet_balance -= amount
            user.save()

            # Log transaction
            WalletTransaction.objects.create(
                user=user,
                transaction_type='debit',
                amount=amount,
                order_id=order_id,
                description='Purchase order'
            )

        return Response({
            'success': True,
            'walletBalance': float(user.wallet_balance),
            'transaction': {
                'type': 'debit',
                'amount': amount,
                'timestamp': timezone.now().isoformat(),
            }
        })
    except Exception as e:
        return Response({'success': False, 'message': str(e)}, status=500)
```

## Database Schemas

### Wallet Transaction Table/Collection

```javascript
// MongoDB
const walletTransactionSchema = new Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  type: {
    type: String,
    enum: ['credit', 'debit'],
    required: true,
  },
  amount: {
    type: Number,
    required: true,
  },
  description: String,
  paymentId: String, // For credit transactions
  orderId: String,   // For debit transactions
  createdAt: {
    type: Date,
    default: Date.now,
  },
});
```

## Authentication Middleware

```javascript
// Express
const authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = authHeader.substring(7);

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    req.userPhone = decoded.phone;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};
```

## Error Handling

Always return these standard error responses:

```javascript
// Authentication Error
{ 
  success: false, 
  message: "Invalid or expired token",
  code: "AUTH_ERROR"
}

// Validation Error
{ 
  success: false, 
  message: "Invalid amount",
  code: "VALIDATION_ERROR"
}

// Insufficient Balance
{ 
  success: false, 
  message: "Insufficient wallet balance",
  availableBalance: 50.0,
  code: "INSUFFICIENT_BALANCE"
}

// Server Error
{ 
  success: false, 
  message: "Internal server error",
  code: "SERVER_ERROR"
}
```

## Testing with cURL

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+919876543210",
    "otp": "123456",
    "name": "John Doe"
  }'
```

### Get Wallet
```bash
curl -X GET http://localhost:3000/api/users/wallet \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Deduct Wallet
```bash
curl -X POST http://localhost:3000/api/users/wallet/deduct \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100.0,
    "orderId": "order_123"
  }'
```

## Rate Limiting (Recommended)

Protect wallet endpoints with rate limiting:

```javascript
const rateLimit = require('express-rate-limit');

const walletLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per windowMs
  message: 'Too many requests, please try again later',
});

router.post('/users/wallet/deduct', walletLimiter, authMiddleware, deductWallet);
```

---

These examples provide a foundation for your backend implementation. Adapt them to your specific framework and database.
