import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop/config/shiprocket_config.dart';

class ShiprocketOrderData {
  final String orderId;
  final String orderStatus;
  final String? courierName;
  final String? trackingNumber;
  final String? estimatedDeliveryDate;
  final List<TrackingEvent> trackingHistory;
  final DeliveryPartner? deliveryPartner;
  final String? currentLocation;

  ShiprocketOrderData({
    required this.orderId,
    required this.orderStatus,
    this.courierName,
    this.trackingNumber,
    this.estimatedDeliveryDate,
    this.trackingHistory = const [],
    this.deliveryPartner,
    this.currentLocation,
  });

  factory ShiprocketOrderData.fromJson(Map<String, dynamic> json) {
    return ShiprocketOrderData(
      orderId: json['order_id']?.toString() ?? json['shipment_id']?.toString() ?? '',
      orderStatus: _mapStatus(json['status'] ?? json['current_status'] ?? 'Unknown'),
      courierName: json['courier_name'] ?? json['carrier_name'],
      trackingNumber: json['awb_code'] ?? json['tracking_number'] ?? json['tracking_id'],
      estimatedDeliveryDate: json['estimated_delivery_date'] ?? json['edd'],
      trackingHistory: (json['tracking_data'] as List?)
              ?.map((e) => TrackingEvent.fromJson(e))
              .toList() ??
          [],
      deliveryPartner: json['delivery_partner'] != null
          ? DeliveryPartner.fromJson(json['delivery_partner'])
          : null,
      currentLocation: json['current_location'] ?? json['location'],
    );
  }

  static String _mapStatus(String status) {
    // Map Shiprocket statuses to user-friendly statuses
    final statusLower = status.toLowerCase();
    if (statusLower.contains('delivered')) return 'Delivered';
    if (statusLower.contains('out for delivery') || statusLower.contains('ofd')) return 'Out for Delivery';
    if (statusLower.contains('in transit') || statusLower.contains('transit')) return 'In Transit';
    if (statusLower.contains('picked up') || statusLower.contains('pickup')) return 'Picked Up';
    if (statusLower.contains('processing') || statusLower.contains('processed')) return 'Processing';
    if (statusLower.contains('cancelled') || statusLower.contains('cancel')) return 'Cancelled';
    return status;
  }
}

class TrackingEvent {
  final String timestamp;
  final String status;
  final String? location;
  final String? remarks;

  TrackingEvent({
    required this.timestamp,
    required this.status,
    this.location,
    this.remarks,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      timestamp: json['timestamp'] ?? json['created_at'] ?? DateTime.now().toString(),
      status: json['status'] ?? json['current_status'] ?? '',
      location: json['location'] ?? json['city'] ?? json['hub'],
      remarks: json['remarks'] ?? json['comment'] ?? json['message'],
    );
  }
}

class DeliveryPartner {
  final String name;
  final String phone;
  final String? email;
  final String? vehicleInfo;
  final double? latitude;
  final double? longitude;
  final String? profileImage;

  DeliveryPartner({
    required this.name,
    required this.phone,
    this.email,
    this.vehicleInfo,
    this.latitude,
    this.longitude,
    this.profileImage,
  });

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return DeliveryPartner(
      name: json['name'] ?? json['delivery_boy_name'] ?? 'Delivery Partner',
      phone: json['phone'] ?? json['delivery_boy_phone'] ?? '',
      email: json['email'],
      vehicleInfo: json['vehicle_info'] ?? json['vehicle_number'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      profileImage: json['profile_image'],
    );
  }
}

class ShiprocketService {
  static const String _baseUrl = ShiprocketConfig.baseUrl;
  static String? _authToken;
  static DateTime? _tokenExpiry;
  static bool _authFailed = false; // Track if authentication has failed

  /// Authenticate with Shiprocket and get access token
  static Future<String?> authenticate() async {
    // Don't retry if authentication already failed
    if (_authFailed) {
      return null;
    }

    try {
      // Note: Shiprocket API v2 uses different endpoint - try both
      // v1 endpoint: /auth/login
      // v2 endpoint might be different or require API key instead
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': ShiprocketConfig.email,
          'password': ShiprocketConfig.password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        // Token typically expires in 24 hours
        _tokenExpiry = DateTime.now().add(const Duration(hours: 23));
        _authFailed = false; // Reset failure flag on success
        return _authToken;
      } else {
        print('Shiprocket Auth Error: ${response.statusCode} - ${response.body}');
        _authFailed = true; // Mark as failed to prevent retries
        return null;
      }
    } catch (e) {
      print('Exception in authenticate: $e');
      _authFailed = true; // Mark as failed to prevent retries
      return null;
    }
  }

  /// Get valid auth token (authenticates if needed)
  static Future<String?> _getAuthToken() async {
    // Don't try if authentication already failed
    if (_authFailed) {
      return null;
    }

    // Check if token exists and is not expired
    if (_authToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _authToken;
    }

    // Authenticate to get new token
    return await authenticate();
  }

  /// Get order tracking details by Shiprocket Order ID
  static Future<ShiprocketOrderData?> getOrderTracking(String orderId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('Failed to authenticate with Shiprocket');
        return null;
      }

      // Remove # if present in order ID
      final cleanOrderId = orderId.replaceAll('#', '');

      final response = await http.get(
        Uri.parse('$_baseUrl/orders/show/$cleanOrderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShiprocketOrderData.fromJson(data['data'] ?? data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getOrderTracking: $e');
      return null;
    }
  }

  /// Get tracking details by AWB (Airway Bill) code
  static Future<ShiprocketOrderData?> getTrackingByAWB(String awbCode) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('Failed to authenticate with Shiprocket');
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/courier/track/awb/$awbCode'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShiprocketOrderData.fromJson(data['data'] ?? data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getTrackingByAWB: $e');
      return null;
    }
  }

  /// Get tracking history for an order
  static Future<List<TrackingEvent>> getTrackingHistory(String orderId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('Failed to authenticate with Shiprocket');
        return [];
      }

      final cleanOrderId = orderId.replaceAll('#', '');

      final response = await http.get(
        Uri.parse('$_baseUrl/orders/show/$cleanOrderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orderData = data['data'] ?? data;
        final trackingList = orderData['tracking_data'] ?? [];
        return (trackingList as List)
            .map((event) => TrackingEvent.fromJson(event))
            .toList();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception in getTrackingHistory: $e');
      return [];
    }
  }

  /// Get delivery partner details for an order
  static Future<DeliveryPartner?> getDeliveryPartner(String orderId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('Failed to authenticate with Shiprocket');
        return null;
      }

      final cleanOrderId = orderId.replaceAll('#', '');

      final response = await http.get(
        Uri.parse('$_baseUrl/orders/show/$cleanOrderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final orderData = data['data'] ?? data;
        
        // Extract delivery partner info if available
        if (orderData['delivery_partner'] != null) {
          return DeliveryPartner.fromJson(orderData['delivery_partner']);
        }
        
        // Try alternative fields
        if (orderData['delivery_boy_name'] != null) {
          return DeliveryPartner(
            name: orderData['delivery_boy_name'] ?? 'Delivery Partner',
            phone: orderData['delivery_boy_phone'] ?? '',
            email: orderData['delivery_boy_email'],
            vehicleInfo: orderData['vehicle_number'],
          );
        }
        
        return null;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getDeliveryPartner: $e');
      return null;
    }
  }

  /// Create a shipment order in Shiprocket
  /// Note: This method should ideally be called from your backend server for security
  /// Parameters match Shiprocket API requirements
  static Future<Map<String, dynamic>?> createShipment({
    required String orderId,
    required String orderDate,
    required String pickupLocation,
    required String billingCustomerName,
    required String billingAddress,
    required String billingCity,
    required String billingPincode,
    required String billingState,
    required String billingCountry,
    required String billingEmail,
    required String billingPhone,
    bool shippingIsBilling = true,
    String? shippingCustomerName,
    String? address,
    String? shippingCity,
    String? shippingPincode,
    String? shippingState,
    String? shippingCountry,
    String? shippingEmail,
    String? shippingPhone,
    required List<Map<String, dynamic>> orderItems, // [{name, sku, units, selling_price, discount}]
    required String paymentMethod, // "Prepaid" or "COD"
    required double subTotal,
    double? length,
    double? breadth,
    double? height,
    double? weight,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        print('Failed to authenticate with Shiprocket');
        return null;
      }

      final Map<String, dynamic> shipmentData = {
        'order_id': orderId,
        'order_date': orderDate,
        'pickup_location': pickupLocation,
        'billing_customer_name': billingCustomerName,
        'billing_address': billingAddress,
        'billing_city': billingCity,
        'billing_pincode': billingPincode,
        'billing_state': billingState,
        'billing_country': billingCountry,
        'billing_email': billingEmail,
        'billing_phone': billingPhone,
        'shipping_is_billing': shippingIsBilling,
        'order_items': orderItems,
        'payment_method': paymentMethod,
        'sub_total': subTotal,
      };

      // Add shipping address if different from billing
      if (!shippingIsBilling) {
        shipmentData['shipping_customer_name'] = shippingCustomerName ?? billingCustomerName;
        shipmentData['shipping_address'] = address ?? billingAddress;
        shipmentData['shipping_city'] = shippingCity ?? billingCity;
        shipmentData['shipping_pincode'] = shippingPincode ?? billingPincode;
        shipmentData['shipping_state'] = shippingState ?? billingState;
        shipmentData['shipping_country'] = shippingCountry ?? billingCountry;
        shipmentData['shipping_email'] = shippingEmail ?? billingEmail;
        shipmentData['shipping_phone'] = shippingPhone ?? billingPhone;
      }

      // Add dimensions if provided
      if (length != null) shipmentData['length'] = length;
      if (breadth != null) shipmentData['breadth'] = breadth;
      if (height != null) shipmentData['height'] = height;
      if (weight != null) shipmentData['weight'] = weight;

      final response = await http.post(
        Uri.parse('$_baseUrl/orders/create/adhoc'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(shipmentData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Shiprocket shipment created successfully: ${data['order_id']}');
        return data;
      } else {
        print('Error creating Shiprocket shipment: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in createShipment: $e');
      return null;
    }
  }

  /// Mock data for development and testing (when API is not configured)
  static ShiprocketOrderData getMockOrderTracking(String orderId) {
    return ShiprocketOrderData(
      orderId: orderId,
      orderStatus: 'In Transit',
      courierName: 'DELHIVERY',
      trackingNumber: 'DEL${orderId.replaceAll('#', '')}',
      estimatedDeliveryDate: DateTime.now().add(const Duration(days: 2)).toString(),
      currentLocation: 'Mumbai Distribution Center',
      deliveryPartner: DeliveryPartner(
        name: 'Raj Kumar',
        phone: '+91 9876543210',
        email: 'raj@shiprocket.in',
        vehicleInfo: 'Maruti Swift - MH02AB1234',
        latitude: 19.0760,
        longitude: 72.8777,
        profileImage: 'https://i.imgur.com/8B0LqOo.png',
      ),
      trackingHistory: [
        TrackingEvent(
          timestamp: DateTime.now().toString(),
          status: 'Out for Delivery',
          location: 'Mumbai, MH',
          remarks: 'Package is out for delivery',
        ),
        TrackingEvent(
          timestamp: DateTime.now().subtract(const Duration(hours: 3)).toString(),
          status: 'In Transit',
          location: 'Vile Parle, Mumbai',
          remarks: 'Package in transit to delivery location',
        ),
        TrackingEvent(
          timestamp: DateTime.now().subtract(const Duration(days: 1)).toString(),
          status: 'Picked Up',
          location: 'Delhi Warehouse',
          remarks: 'Package picked up from warehouse',
        ),
        TrackingEvent(
          timestamp: DateTime.now().subtract(const Duration(days: 2)).toString(),
          status: 'Order Confirmed',
          location: 'Delhi',
          remarks: 'Order confirmed and packaged',
        ),
      ],
    );
  }

  /// Verify Shiprocket API credentials
  static Future<bool> verifyCredentials() async {
    try {
      final token = await authenticate();
      return token != null;
    } catch (e) {
      print('Exception in verifyCredentials: $e');
      return false;
    }
  }
}
