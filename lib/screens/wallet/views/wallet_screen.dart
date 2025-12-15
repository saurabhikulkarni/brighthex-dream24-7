import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/razorpay_service.dart';
import 'package:uuid/uuid.dart';

import 'components/wallet_balance_card.dart';
import 'components/wallet_history_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double walletBalance = 0.0;
  int shoppingTokens = 0;
  final TextEditingController _amountController = TextEditingController();
  double _selectedTopUpAmount = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args.isNotEmpty) {
      setState(() {
        walletBalance = (args['walletBalance'] ?? 0.0) as double;
        shoppingTokens = (args['shoppingTokens'] ?? 0) as int;
      });
    }
  }

  void _addMoney(double amount) {
    setState(() {
      walletBalance += amount;
      shoppingTokens += amount.toInt();
      _selectedTopUpAmount = 0;
      _amountController.clear();
    });
  }

  void _initiatePayment() {
    const uuid = Uuid();
    final orderId = '#${uuid.v4().substring(0, 8).toUpperCase()}';

    final razorpayService = RazorpayService();
    
    razorpayService.startPayment(
      orderId: orderId,
      amount: _selectedTopUpAmount,
      userEmail: 'user@example.com',
      userPhone: '+91 9999999999',
      userName: 'Customer',
      onSuccess: (response) {
        // Payment successful, add money to wallet
        _addMoney(_selectedTopUpAmount);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Successfully added \$${_selectedTopUpAmount.toStringAsFixed(2)} to wallet",
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      },
      onError: (error) {
        // Payment failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Payment failed: $error",
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      },
      onDismiss: () {
        // Payment dismissed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Payment cancelled",
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Widget _buildQuickSelectButton(double amount) {
    final isSelected = _selectedTopUpAmount == amount;
    return SizedBox(
      width: 90,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedTopUpAmount = amount;
            _amountController.text = amount.toStringAsFixed(0);
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isSelected ? const Color(0xFF219A00) : Colors.grey[400]!,
            width: 2,
          ),
          backgroundColor: isSelected ? const Color(0xFF219A00).withOpacity(0.1) : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          children: [
            const Text(
              "Add",
              style: TextStyle(fontSize: 10),
            ),
            Text(
              "\$${amount.toStringAsFixed(0)}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? const Color(0xFF219A00) : Colors.grey[600],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop({
          'walletBalance': walletBalance,
          'shoppingTokens': shoppingTokens,
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Wallet"),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WalletBalanceCard(
                          balance: walletBalance,
                          shoppingTokens: shoppingTokens,
                          onTabChargeBalance: () {},
                        ),
                        const SizedBox(height: defaultPadding * 2),
                        // Add Top-up Section
                        Text(
                          "Add Top-up",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding),
                        // Input field
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              if (value.isEmpty) {
                                _selectedTopUpAmount = 0;
                              } else {
                                _selectedTopUpAmount = double.tryParse(value) ?? 0;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Enter amount here",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: defaultPadding),
                        // Quick select buttons
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildQuickSelectButton(50),
                              const SizedBox(width: 12),
                              _buildQuickSelectButton(100),
                              const SizedBox(width: 12),
                              _buildQuickSelectButton(200),
                            ],
                          ),
                        ),
                        const SizedBox(height: defaultPadding * 1.5),
                        // Add Top-up button
                        ElevatedButton(
                          onPressed: _selectedTopUpAmount > 0
                              ? () {
                                  _initiatePayment();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedTopUpAmount > 0
                                ? const Color(0xFF219A00)
                                : Colors.grey[400],
                            disabledBackgroundColor: Colors.grey[400],
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(defaultBorderRadious),
                            ),
                          ),
                          child: Text(
                            _selectedTopUpAmount > 0
                                ? "Add \$${_selectedTopUpAmount.toStringAsFixed(0)}"
                                : "Add Top-up",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: defaultPadding / 2),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      "Wallet history",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(top: defaultPadding),
                      child: WalletHistoryCard(
                        isReturn: index == 1,
                        date: "JUN 12, 2020",
                        amount: 129,
                        products: [
                          ProductModel(
                            image: productDemoImg1,
                            title: "Mountain Warehouse for Women",
                            brandName: "Lipsy london",
                            price: 540,
                          ),
                          ProductModel(
                            image: productDemoImg4,
                            title: "Mountain Beta Warehouse",
                            brandName: "Lipsy london",
                            price: 800,
                          ),
                        ],
                      ),
                    ),
                    childCount: 4,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
