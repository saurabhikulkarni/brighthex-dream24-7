import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      walletBalance = (args['walletBalance'] ?? 0.0) as double;
      shoppingTokens = (args['shoppingTokens'] ?? 0) as int;
    }
  }

  void _addMoney(double amount) {
    setState(() {
      walletBalance += amount;
      shoppingTokens += amount.toInt();
    });
    // TODO: Persist wallet and token state
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
                          onTabChargeBalance: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Add Money to Wallet'),
                                  content: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Enter amount',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        final amount = double.tryParse(_amountController.text);
                                        if (amount != null && amount > 0) {
                                          _addMoney(amount);
                                          _amountController.clear();
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text('Shopping Tokens: $shoppingTokens', style: const TextStyle(fontSize: 16)),
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
                            priceAfetDiscount: 420,
                            dicountpercent: 20,
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
