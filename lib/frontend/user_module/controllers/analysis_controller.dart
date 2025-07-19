import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class AnalysisController extends GetxController {
  final TransactionService _service = TransactionService();
  
  var transactions = <TransactionModel>[].obs;
  var filteredTransactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  

  
  @override
  void onInit() {
    super.onInit();
    fetchTransactions('687a5088ef80ce4d11f829aa'); // Default user ID
  }
  
  Future<void> fetchTransactions(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final fetchedTransactions = await _service.fetchTransactionsByUser(userId);
      transactions.value = fetchedTransactions;
      filteredTransactions.value = fetchedTransactions; // Use all transactions
      
    } catch (e) {
      errorMessage.value = 'Failed to load transactions: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Get expense data for pie chart
  Map<String, double> getExpenseData() {
    final expenseTransactions = filteredTransactions
        .where((tx) => tx.isExpense)
        .toList();
    
    final Map<String, double> categoryTotals = {};
    
    for (var transaction in expenseTransactions) {
      final category = transaction.category;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction.amount;
    }
    
    return categoryTotals;
  }
  
  // Get income data for pie chart
  Map<String, double> getIncomeData() {
    final incomeTransactions = filteredTransactions
        .where((tx) => !tx.isExpense)
        .toList();
    
    final Map<String, double> categoryTotals = {};
    
    for (var transaction in incomeTransactions) {
      final category = transaction.category;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction.amount;
    }
    
    return categoryTotals;
  }
  
  // Get expense data for line chart (grouped by date)
  Map<DateTime, double> getExpenseLineData() {
    final expenseTransactions = filteredTransactions
        .where((tx) => tx.isExpense)
        .toList();
    
    final Map<DateTime, double> dateTotals = {};
    
    for (var transaction in expenseTransactions) {
      final date = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );
      dateTotals[date] = (dateTotals[date] ?? 0) + transaction.amount;
    }
    
    return dateTotals;
  }
  
  // Get income data for line chart (grouped by date)
  Map<DateTime, double> getIncomeLineData() {
    final incomeTransactions = filteredTransactions
        .where((tx) => !tx.isExpense)
        .toList();
    
    final Map<DateTime, double> dateTotals = {};
    
    for (var transaction in incomeTransactions) {
      final date = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );
      dateTotals[date] = (dateTotals[date] ?? 0) + transaction.amount;
    }
    
    return dateTotals;
  }
  
  // Get total expenses
  double get totalExpenses {
    return filteredTransactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  
  // Get total income
  double get totalIncome {
    return filteredTransactions
        .where((tx) => !tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  
  // Get net amount (income - expenses)
  double get netAmount {
    return totalIncome - totalExpenses;
  }
  

} 