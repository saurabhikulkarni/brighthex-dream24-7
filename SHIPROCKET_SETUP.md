# Shiprocket Integration Setup Guide

## Overview
This app integrates with Shiprocket API for order tracking functionality.

## Setup Instructions

### 1. Get Shiprocket API Credentials

1. Go to [Shiprocket Dashboard](https://app.shiprocket.in/)
2. Login to your account
3. Navigate to **Settings** → **API**
4. Note down your **Email** and **Password** (the ones you use to login)

### 2. Configure Credentials

Open `lib/config/shiprocket_config.dart` and update:

```dart
static const String email = 'your-email@example.com';
static const String password = 'your-password';
```

### 3. API Endpoints Used

The integration uses the following Shiprocket API endpoints:

- **Authentication**: `POST /auth/login`
- **Get Order Details**: `GET /orders/show/{order_id}`
- **Track by AWB**: `GET /courier/track/awb/{awb_code}`

### 4. Features Implemented

✅ **Order Tracking**
- Real-time order status
- Tracking history timeline
- Estimated delivery date
- Current location

✅ **Delivery Partner Info**
- Delivery partner name and contact
- Vehicle information
- Location tracking

✅ **Automatic Token Management**
- Auto-authentication
- Token refresh handling
- Secure token storage

### 5. Testing

The app will automatically:
- Use **mock data** if credentials are not configured
- Use **real API** if credentials are configured
- Show **error messages** if API calls fail

### 6. Order ID Format

- Order IDs can be passed with or without `#` prefix
- Example: `#123456` or `123456` both work
- The service automatically cleans the order ID

### 7. Status Mapping

Shiprocket statuses are automatically mapped to user-friendly statuses:
- `delivered` → "Delivered"
- `out_for_delivery` / `ofd` → "Out for Delivery"
- `in_transit` → "In Transit"
- `picked_up` → "Picked Up"
- `processing` → "Processing"
- `cancelled` → "Cancelled"

## Troubleshooting

### API Authentication Fails
- Verify your email and password are correct
- Check if your Shiprocket account is active
- Ensure API access is enabled in your Shiprocket account

### No Tracking Data
- Verify the order ID exists in Shiprocket
- Check if the order has been shipped
- Some orders may not have tracking data until shipment is created

### Token Expiry
- Tokens expire after 24 hours
- The service automatically re-authenticates when needed
- No manual intervention required

## Security Notes

⚠️ **Important**: 
- Never commit credentials to version control
- Use environment variables or secure storage for production
- Consider using `flutter_secure_storage` for sensitive data

## Support

For Shiprocket API documentation, visit:
https://apidocs.shiprocket.in/
