import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shop/models/payment_model.dart';
import 'package:shop/services/graphql_client.dart';
import 'package:shop/services/graphql_queries.dart';
import 'package:shop/services/user_service.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  
  factory PaymentService() {
    return _instance;
  }
  
  PaymentService._internal();

  final GraphQLClient _client = GraphQLService.getClient();

  // Convert PaymentStatus enum to string
  String _paymentStatusToString(PaymentStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }

  // Convert string to PaymentStatus enum
  PaymentStatus _stringToPaymentStatus(String statusStr) {
    final statusLower = statusStr.toLowerCase();
    if (statusLower == 'pending') return PaymentStatus.pending;
    if (statusLower == 'processing') return PaymentStatus.processing;
    if (statusLower == 'completed') return PaymentStatus.completed;
    if (statusLower == 'failed') return PaymentStatus.failed;
    if (statusLower == 'cancelled') return PaymentStatus.cancelled;
    if (statusLower == 'refunded') return PaymentStatus.refunded;
    return PaymentStatus.pending;
  }

  // Convert PaymentMethod enum to string (nullable)
  String? _paymentMethodToString(PaymentMethod? method) {
    if (method == null) return null;
    return method.toString().split('.').last.toLowerCase();
  }

  // Convert string to PaymentMethod enum
  PaymentMethod? _stringToPaymentMethod(String? methodStr) {
    if (methodStr == null || methodStr.isEmpty) return null;
    final methodLower = methodStr.toLowerCase();
    try {
      return PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == methodLower,
      );
    } catch (e) {
      return null;
    }
  }

  // Get all payments for current user
  Future<List<PaymentModel>> getUserPayments({bool newestFirst = true}) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getUserPayments),
          variables: {
            'userId': userId,
            'orderBy': newestFirst ? 'createdAt_DESC' : 'createdAt_ASC',
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['payments'] == null) {
        return [];
      }

      final List<dynamic> paymentsJson = result.data!['payments'] as List<dynamic>;
      return paymentsJson
          .map((json) => _paymentFromGraphQL(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching payments: $e');
    }
  }

  // Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getPaymentById),
          variables: {'id': paymentId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['payment'] == null) {
        return null;
      }

      return _paymentFromGraphQL(result.data!['payment'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching payment: $e');
    }
  }

  // Get payment by Razorpay order ID
  Future<PaymentModel?> getPaymentByRazorpayOrderId(String razorpayOrderId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getPaymentByRazorpayOrderId),
          variables: {'razorpayOrderId': razorpayOrderId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['payment'] == null) {
        return null;
      }

      return _paymentFromGraphQL(result.data!['payment'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching payment: $e');
    }
  }

  // Create payment record
  Future<PaymentModel> createPayment(PaymentModel payment) async {
    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.createPayment),
        variables: {
          'userId': userId,
          'razorpayOrderId': payment.razorpayOrderId ?? '',
          'razorpayPaymentId': payment.razorpayPaymentId,
          'amount': payment.amount,
          'currency': payment.currency,
          'status': _paymentStatusToString(payment.status),
          'method': _paymentMethodToString(payment.method),
          'orderId': payment.orderId,
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final createdPayment = result.data?['createPayment'];
      if (createdPayment == null) {
        throw Exception('Failed to create payment');
      }

      // Publish payment
      final paymentId = createdPayment['id']?.toString();
      if (paymentId != null) {
        await _publishPayment(paymentId);
      }

      return _paymentFromGraphQL({
        ...createdPayment as Map<String, dynamic>,
        'orderId': payment.orderId,
      });
    } catch (e) {
      throw Exception('Error creating payment: $e');
    }
  }

  // Update payment status
  Future<PaymentModel> updatePaymentStatus(String paymentId, PaymentStatus status) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updatePaymentStatus),
        variables: {
          'id': paymentId,
          'status': _paymentStatusToString(status),
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final updatedPayment = result.data?['updatePayment'];
      if (updatedPayment == null) {
        throw Exception('Failed to update payment status');
      }

      // Get full payment to return
      return await getPaymentById(paymentId) ?? 
          throw Exception('Payment not found after update');
    } catch (e) {
      throw Exception('Error updating payment status: $e');
    }
  }

  // Update payment with Razorpay payment ID (after successful payment)
  Future<PaymentModel> updatePaymentWithRazorpayId(
    String paymentId,
    String razorpayPaymentId,
    PaymentStatus status,
  ) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql(GraphQLQueries.updatePaymentWithRazorpayId),
        variables: {
          'id': paymentId,
          'razorpayPaymentId': razorpayPaymentId,
          'status': _paymentStatusToString(status),
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final updatedPayment = result.data?['updatePayment'];
      if (updatedPayment == null) {
        throw Exception('Failed to update payment');
      }

      // Get full payment to return
      return await getPaymentById(paymentId) ?? 
          throw Exception('Payment not found after update');
    } catch (e) {
      throw Exception('Error updating payment: $e');
    }
  }

  // Helper: Convert GraphQL JSON to PaymentModel
  PaymentModel _paymentFromGraphQL(Map<String, dynamic> json) {
    // Extract orderId from order relation or direct field
    String? orderId;
    if (json['orderId'] != null) {
      orderId = json['orderId']?.toString();
    } else if (json['order'] != null) {
      orderId = json['order']?['id']?.toString() ?? json['order']?['orderNumber'];
    }

    return PaymentModel(
      paymentId: json['id']?.toString() ?? '',
      orderId: orderId ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      status: _stringToPaymentStatus(json['status']?.toString() ?? 'pending'),
      method: _stringToPaymentMethod(json['method']?.toString()),
      razorpayPaymentId: json['razorpayPaymentId']?.toString(),
      razorpayOrderId: json['razorpayOrderId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      completedAt: json['updatedAt'] != null &&
              _stringToPaymentStatus(json['status']?.toString() ?? '') == PaymentStatus.completed
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Helper: Publish payment
  Future<void> _publishPayment(String paymentId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishPayment),
          variables: {'id': paymentId},
        ),
      );
    } catch (e) {
      print('Error publishing payment: $e');
      // Non-critical error
    }
  }
}

// Global instance
final paymentService = PaymentService();
