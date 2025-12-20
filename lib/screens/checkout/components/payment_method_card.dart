import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/payment_model.dart';
import 'package:shop/services/razorpay_service.dart';

class PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          border: Border.all(
            color: isSelected ? const Color(0xFF6441A5) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? const Color(0xFF6441A5).withOpacity(0.05)
              : Colors.white,
        ),
        child: Column(
          children: [
            // Payment Method Icon
            Container(
              padding: const EdgeInsets.all(defaultPadding / 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF6441A5).withOpacity(0.1)
                    : Colors.grey.shade100,
              ),
              child: SvgPicture.asset(
                RazorpayService().getPaymentMethodIcon(method),
                height: 32,
                width: 32,
                colorFilter: ColorFilter.mode(
                  isSelected ? const Color(0xFF6441A5) : Colors.grey.shade600,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            // Payment Method Name
            Text(
              RazorpayService().getPaymentMethodName(method),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF6441A5) : Colors.grey.shade700,
              ),
            ),
            // Selection Indicator
            if (isSelected) ...[
              const SizedBox(height: defaultPadding / 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6441A5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PaymentHistoryCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback? onTap;

  const PaymentHistoryCard({
    super.key,
    required this.payment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        margin: const EdgeInsets.only(bottom: defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with amount and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order ${payment.orderId}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      RazorpayService().formatAmount(payment.amount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6441A5),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding / 2,
                    vertical: defaultPadding / 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(int.parse(
                      'FF${RazorpayService().getStatusColor(payment.paymentStatus).replaceFirst('#', '')}',
                      radix: 16,
                    )).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    RazorpayService().getStatusText(payment.paymentStatus),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(int.parse(
                        'FF${RazorpayService().getStatusColor(payment.paymentStatus).replaceFirst('#', '')}',
                        radix: 16,
                      )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            const Divider(),
            const SizedBox(height: defaultPadding),
            // Payment details
            _buildDetailRow('Payment ID', payment.razorpayPaymentId ?? 'N/A'),
            _buildDetailRow(
              'Payment Method',
              payment.method != null
                  ? RazorpayService().getPaymentMethodName(payment.method!)
                  : 'N/A',
            ),
            _buildDetailRow(
              'Date',
              payment.createdAt.toString().split('.')[0],
            ),
            if (payment.failureReason != null)
              _buildDetailRow('Reason', payment.failureReason!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A0845),
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class PaymentLoadingDialog extends StatelessWidget {
  final String message;

  const PaymentLoadingDialog({
    super.key,
    this.message = 'Processing payment...',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFF6441A5)),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2A0845),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              'Please wait, do not close the app',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessDialog extends StatelessWidget {
  final String orderId;
  final double amount;
  final String paymentId;
  final VoidCallback onContinue;

  const PaymentSuccessDialog({
    super.key,
    required this.orderId,
    required this.amount,
    required this.paymentId,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: const BoxDecoration(
                color: Color(0xFF219A00),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            const Text(
              'Payment Successful!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A0845),
              ),
            ),
            const SizedBox(height: defaultPadding),
            _buildDetailRow('Order ID', orderId),
            _buildDetailRow('Amount', RazorpayService().formatAmount(amount)),
            _buildDetailRow('Payment ID', paymentId),
            const SizedBox(height: defaultPadding * 2),
            ElevatedButton(
              onPressed: onContinue,
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A0845),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentErrorDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const PaymentErrorDialog({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(defaultPadding * 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: const BoxDecoration(
                color: Color(0xFFF44336),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            const Text(
              'Payment Failed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A0845),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: defaultPadding * 2),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
