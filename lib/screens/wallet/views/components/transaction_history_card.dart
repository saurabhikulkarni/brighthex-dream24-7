import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../constants.dart';

class TransactionHistoryCard extends StatelessWidget {
  const TransactionHistoryCard({
    super.key,
    required this.transactionType,
    required this.date,
    required this.amount,
    required this.isIncome,
  });

  final String transactionType; // "Top-up", "Withdrawal", "Transfer", "Purchase", etc.
  final String date;
  final double amount;
  final bool isIncome; // true = green/income, false = red/debit

  String _getIcon() {
    switch (transactionType.toLowerCase()) {
      case 'top-up':
        return "assets/icons/Plus1.svg";
      case 'purchase':
        return "assets/icons/Return.svg";
      default:
        return "assets/icons/Product.svg";
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountStr = amount.toStringAsFixed(0);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 1.5,
      ),
      decoration: BoxDecoration(
        borderRadius:
            const BorderRadius.all(Radius.circular(defaultBorderRadious)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 48,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(
              _getIcon(),
              color: isIncome ? Colors.green : Colors.red,
              height: 24,
              width: 24,
            ),
          ),
        ),
        title: Text(
          transactionType,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Text(
          date,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium!.color,
          ),
        ),
        trailing: Text(
          isIncome ? "+ ₹$amountStr" : "- ₹$amountStr",
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
