import 'dart:convert';
import 'package:http/http.dart' as http;

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
      orderId: json['order_id']?.toString() ?? '',
      orderStatus: json['status'] ?? 'Unknown',
      courierName: json['courier_name'],
      trackingNumber: json['tracking_number'],
      estimatedDeliveryDate: json['estimated_delivery_date'],
      trackingHistory: (json['tracking_history'] as List?)
              ?.map((e) => TrackingEvent.fromJson(e))
              .toList() ??
          [],
      deliveryPartner: json['delivery_partner'] != null
          ? DeliveryPartner.fromJson(json['delivery_partner'])
          : null,
      currentLocation: json['current_location'],
    );
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
      timestamp: json['timestamp'] ?? '',
      status: json['status'] ?? '',
      location: json['location'],
      remarks: json['remarks'],
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
      name: json['name'] ?? 'Delivery Partner',
      phone: json['phone'] ?? '',
      email: json['email'],
      vehicleInfo: json['vehicle_info'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      profileImage: json['profile_image'],
    );
  }
}

class ShiprocketService {
  // Replace with your actual Shiprocket API credentials
  static const String _baseUrl = 'https://apiv2.shiprocket.in/v1/external';
  static const String _apiKey = 'YOUR_SHIPROCKET_API_KEY';
  
  // For demo purposes - in production, use proper authentication
  static const String _authToken = 'Bearer $_apiKey';

  /// Get order tracking details
  static Future<ShiprocketOrderData?> getOrderTracking(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId/track'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken,
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

  /// Get delivery partner details for an order
  static Future<DeliveryPartner?> getDeliveryPartner(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId/partner'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DeliveryPartner.fromJson(data['data'] ?? data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception in getDeliveryPartner: $e');
      return null;
    }
  }

  /// Get tracking history for an order
  static Future<List<TrackingEvent>> getTrackingHistory(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/orders/$orderId/tracking'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final trackingList = data['data']['tracking_data'] ?? [];
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

  /// Mock data for development and testing
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

  /// Verify Shiprocket API key
  static Future<bool> verifyApiKey(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/account/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Exception in verifyApiKey: $e');
      return false;
    }
  }
}
