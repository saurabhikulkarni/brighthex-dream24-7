# Shiprocket Integration Guide

This app now includes full integration with **Shiprocket** for real-time order tracking and delivery partner information.

## Features Implemented

✅ **Order Tracking**
- Real-time order status updates
- Tracking history with timeline view
- Current location and estimated delivery date

✅ **Delivery Partner Tracking**
- Delivery partner name and contact information
- Vehicle information display
- Direct call functionality to delivery partner

✅ **Order Management**
- View all orders with status indicators
- Click "Track" button to view detailed tracking
- Color-coded status badges (Delivered, In Transit, Processing)

✅ **Tracking Timeline**
- Visual timeline of all tracking events
- Status icons for each event
- Relative time display (minutes/hours/days ago)
- Event location and remarks

## Setup Instructions

### 1. Get Shiprocket API Key

1. Sign up at [Shiprocket](https://app.shiprocket.in)
2. Go to Settings → API Key
3. Copy your API key

### 2. Configure API Key

Update the API key in `lib/config/shiprocket_config.dart`:

```dart
static const String apiKey = 'YOUR_SHIPROCKET_API_KEY_HERE';
```

### 3. Update Services

If using production Shiprocket API, update `lib/services/shiprocket_service.dart`:

```dart
static const String _apiKey = ShiprocketConfig.apiKey;
```

### 4. Enable/Disable Mock Data

For development, the app uses mock data by default. To use real Shiprocket API:

In `lib/screens/order/views/order_tracking_screen.dart`, change:

```dart
// From mock data
return ShiprocketService.getMockOrderTracking(widget.orderId);

// To real API
return ShiprocketService.getOrderTracking(widget.orderId);
```

## File Structure

```
lib/
├── config/
│   └── shiprocket_config.dart          # API configuration
├── services/
│   └── shiprocket_service.dart         # Shiprocket API integration
├── models/
│   └── order_model.dart                # Order data model
└── screens/
    └── order/
        ├── views/
        │   ├── orders_screen.dart      # Order list with tracking
        │   └── order_tracking_screen.dart  # Detailed tracking view
        └── components/
            ├── delivery_partner_card.dart  # Delivery partner UI
            └── tracking_timeline.dart      # Timeline component
```

## API Endpoints Used

### Get Order Tracking
```
GET /v1/external/orders/{order_id}/track
```
Returns order status, courier info, and tracking events.

### Get Delivery Partner
```
GET /v1/external/orders/{order_id}/partner
```
Returns delivery partner details and real-time location.

### Get Tracking History
```
GET /v1/external/orders/{order_id}/tracking
```
Returns complete tracking history with all events.

## Data Models

### ShiprocketOrderData
```dart
ShiprocketOrderData(
  orderId: String,
  orderStatus: String,
  courierName: String?,
  trackingNumber: String?,
  estimatedDeliveryDate: String?,
  trackingHistory: List<TrackingEvent>,
  deliveryPartner: DeliveryPartner?,
  currentLocation: String?,
)
```

### DeliveryPartner
```dart
DeliveryPartner(
  name: String,
  phone: String,
  email: String?,
  vehicleInfo: String?,
  latitude: double?,
  longitude: double?,
  profileImage: String?,
)
```

### TrackingEvent
```dart
TrackingEvent(
  timestamp: String,
  status: String,
  location: String?,
  remarks: String?,
)
```

## Usage Example

### View Order Tracking
```dart
// From OrdersScreen, tap "Track" button
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OrderTrackingScreen(orderId: "#123456"),
  ),
);
```

### Get Tracking Data Programmatically
```dart
// Get tracking details
final trackingData = await ShiprocketService.getOrderTracking("#123456");

// Get delivery partner info
final partner = await ShiprocketService.getDeliveryPartner("#123456");

// Get tracking history
final history = await ShiprocketService.getTrackingHistory("#123456");
```

## Shiprocket API Documentation

For more details, visit:
- [Shiprocket API Docs](https://apidocs.shiprocket.in/)
- [Order Tracking API](https://apidocs.shiprocket.in/#0938b6f9-0ba9-4e3d-87fa-bfa2eb76e8b3)

## Status Color Mapping

| Status | Color |
|--------|-------|
| Delivered | Green (#219A00) |
| In Transit / Out for Delivery | Orange |
| Processing | Blue |
| Cancelled | Red |
| Unknown | Grey |

## Error Handling

The service includes built-in error handling:
- Network timeouts (10 seconds)
- API error responses
- Invalid data format handling
- Fallback to mock data for testing

## Future Enhancements

- [ ] Real-time location tracking on map
- [ ] SMS/Email notifications for status updates
- [ ] Webhook integration for automatic updates
- [ ] Multiple order tracking on single map
- [ ] Return/Exchange management
- [ ] Delivery proof with signature/photo
- [ ] Rating and review after delivery

## Troubleshooting

### API Key Not Working
- Verify API key is active in Shiprocket dashboard
- Check API key has correct permissions
- Ensure environment is correct (production/sandbox)

### Orders Not Found
- Verify order ID format is correct
- Ensure order exists in Shiprocket system
- Check order creation date (may take time to sync)

### Missing Delivery Partner
- Order may not be assigned to partner yet
- Check order status in Shiprocket dashboard
- Delivery partner details appear once order is shipped

## Support

For issues or questions:
1. Check Shiprocket API documentation
2. Review error messages in console
3. Test API key with Shiprocket's test endpoint
4. Contact Shiprocket support team

---

**Note:** Always keep your API key secure. Never commit it to version control. Use environment variables in production.
