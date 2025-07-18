import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controllers/transaction_controller.dart';
import '../models/transaction_model.dart';

class HomePage extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());
  // Use a valid MongoDB ObjectId format (24 characters)
  final String currentUserId = "68793739added15012c8ea8c"; // Same as used in controller

  HomePage({super.key}) {
    print('HomePage: Initializing with userId: $currentUserId');
    controller.fetchTransactions(currentUserId);
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  RxBool isExpense = true.obs;

  void _showAddTransactionSheet(BuildContext context) {
    amountController.clear();
    descriptionController.clear();
    categoryController.clear();
    isExpense.value = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter amount' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) =>
                    value!.isEmpty ? 'Enter category' : null,
                  ),
                  Row(
                    children: [
                      const Text("Is Expense?"),
                      Obx(
                        () =>  Switch(
                          value: isExpense.value,
                          onChanged: (val) {
                            isExpense.value = val;
                          },
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    child: const Text("Add Transaction"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print('HomePage: Form validated, creating transaction...');
                        print('HomePage: Amount: ${amountController.text}');
                        print('HomePage: Description: ${descriptionController.text}');
                        print('HomePage: Category: ${categoryController.text}');
                        print('HomePage: IsExpense: ${isExpense.value}');
                        print('HomePage: UserId: $currentUserId');
                        
                        final transaction = TransactionModel(
                          userId: currentUserId,
                          amount: double.parse(amountController.text),
                          description: descriptionController.text,
                          category: categoryController.text,
                          isExpense: isExpense.value,
                          transactionDate: DateTime.now(),
                        );
                        
                        print('HomePage: Created transaction model: $transaction');
                        controller.addTransaction(transaction);
                        print('HomePage: Called controller.addTransaction');
                        
                        // Close the bottom sheet
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Obx(() {
        final txs = controller.transactions;
        final totalSpend = txs
            .where((e) => e.isExpense)
            .fold(0.0, (sum, e) => sum + e.amount);

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red,
              child: Text(
                'Total Spend: ₹${totalSpend.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: txs.length,
                itemBuilder: (_, index) {
                  final tx = txs[index];
                  return ListTile(
                    leading: Icon(
                      tx.isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tx.isExpense ? Colors.red : Colors.green,
                    ),
                    title: Text(tx.category),
                    subtitle: Text(tx.description ?? 'No description'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color:
                                tx.isExpense ? Colors.red : Colors.green,
                              ),
                            ),
                            Text(
                              tx.transactionDate.toLocal().toString().split(' ')[0],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Transaction'),
                                  content: Text('Are you sure you want to delete this ${tx.isExpense ? 'expense' : 'income'} of ₹${tx.amount.toStringAsFixed(2)}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        print('HomePage: Deleting transaction: ${tx.transactionId}');
                                        controller.deleteTransaction(tx.transactionId!);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
