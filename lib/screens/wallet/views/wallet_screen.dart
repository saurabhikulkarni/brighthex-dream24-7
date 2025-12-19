import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/razorpay_service.dart';
import 'package:shop/services/user_service.dart';
import 'package:uuid/uuid.dart';

import 'components/transaction_history_card.dart';
import 'components/wallet_balance_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double walletBalance = 0.0;
  int shoppingTokens = 0;
  double? requiredAmount;
  bool returnToCart = false;
  final TextEditingController _amountController = TextEditingController();
  double _selectedTopUpAmount = 0.0;
  final UserService _userService = userService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get arguments passed from navigation
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args.isNotEmpty) {
      setState(() {
        walletBalance = (args['walletBalance'] ?? 0.0) as double;
        shoppingTokens = (args['shoppingTokens'] ?? 0) as int;
        requiredAmount = args['requiredAmount'] as double?;
        returnToCart = args['returnToCart'] ?? false;
      });
      
      // If required amount is specified, pre-fill it
      if (requiredAmount != null && requiredAmount! > 0) {
        _selectedTopUpAmount = requiredAmount!;
        _amountController.text = requiredAmount!.toStringAsFixed(0);
      }
    }
    
    // Load balance from GraphQL if user is logged in
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final userId = UserService.getCurrentUserId();
    if (userId != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final balance = await _userService.getWalletBalance();
        if (mounted) {
          setState(() {
            walletBalance = balance;
            shoppingTokens = balance.toInt();
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _addMoney(double amount) async {
    final userId = UserService.getCurrentUserId();
    
    if (userId != null) {
      // Update balance in GraphQL
      try {
        final newBalance = await _userService.addWalletBalance(userId, amount);
        if (newBalance != null && mounted) {
          setState(() {
            walletBalance = newBalance;
            shoppingTokens = newBalance.toInt();
            _selectedTopUpAmount = 0;
            _amountController.clear();
          });
        }
      } catch (e) {
        // If GraphQL update fails, update locally
        if (mounted) {
          setState(() {
            walletBalance += amount;
            shoppingTokens += amount.toInt();
            _selectedTopUpAmount = 0;
            _amountController.clear();
          });
        }
      }
    } else {
      // Local update if no user ID
      setState(() {
        walletBalance += amount;
        shoppingTokens += amount.toInt();
        _selectedTopUpAmount = 0;
        _amountController.clear();
      });
    }
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
      onSuccess: (response) async {
        // Payment successful, add money to wallet
        await _addMoney(_selectedTopUpAmount);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Successfully added ₹${_selectedTopUpAmount.toStringAsFixed(2)} to wallet",
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // If returning to cart, pop with updated balance
        if (returnToCart) {
          Navigator.pop(context, {
            'walletBalance': walletBalance,
            'shoppingTokens': shoppingTokens,
          });
        }
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
            duration: Duration(seconds: 2),
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
              "₹${amount.toStringAsFixed(0)}",
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
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
                              if (requiredAmount != null && requiredAmount! > 0) ...[
                                const SizedBox(height: defaultPadding),
                                Container(
                                  padding: const EdgeInsets.all(defaultPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                                    border: Border.all(color: Colors.orange.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                                      const SizedBox(width: defaultPadding / 2),
                                      Expanded(
                                        child: Text(
                                          'You need ${requiredAmount!.toInt()} more tokens to complete your purchase',
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                      ? "Add ₹${_selectedTopUpAmount.toStringAsFixed(0)}"
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
                            "Transaction History",
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final transactions = [
                              {
                                'type': 'Top-up',
                                'date': '28-09-2025',
                                'amount': 150.0,
                                'isIncome': true,
                              },
                              {
                                'type': 'Purchase',
                                'date': '25-09-2025',
                                'amount': 200.0,
                                'isIncome': false,
                              },
                              {
                                'type': 'Purchase',
                                'date': '22-09-2025',
                                'amount': 50.0,
                                'isIncome': false,
                              },
                              {
                                'type': 'Top-up',
                                'date': '20-09-2025',
                                'amount': 100.0,
                                'isIncome': true,
                              },
                            ];

                            final transaction = transactions[index];
                            return Padding(
                              padding: const EdgeInsets.only(top: defaultPadding),
                              child: TransactionHistoryCard(
                                transactionType: transaction['type'] as String,
                                date: transaction['date'] as String,
                                amount: transaction['amount'] as double,
                                isIncome: transaction['isIncome'] as bool,
                              ),
                            );
                          },
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
