import 'package:get/get.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';

class TransactionController extends GetxController{
  final TransactionService _service = TransactionService();

  var transactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Call fetchTransactions without async in onInit
    fetchTransactions('68793739added15012c8ea8c');
  }

  Future<void> fetchTransactions(String userId) async{
    try{
      isLoading.value = true;
      errorMessage.value = '';
      print('Starting to fetch transactions for user: $userId');
      
      final fetched = await _service.fetchTransactionsByUser(userId);
      print(':::::::::::::::::::::::::::::::; $fetched');
      print('Number of transactions fetched: ${fetched.length}');
      
      transactions.assignAll(fetched);
      print('Transactions assigned to observable: ${transactions.length}');
    }catch (e){
      print('Error in fetchTransactions: $e');
      errorMessage.value = e.toString();
    }finally{
      isLoading.value = false;
      print('Fetch transactions completed. Loading: ${isLoading.value}');
    }
  }

  Future<void> addTransaction(TransactionModel txn) async{
    try{
      print('TransactionController: Starting to add transaction: $txn');
      isLoading.value = true;
      errorMessage.value = '';
      
      final success = await _service.addTransaction(txn);
      print('TransactionController: Add transaction result: $success');
      
      if(success){
        print('TransactionController: Adding transaction to local list');
        transactions.add(txn);
        print('TransactionController: Transaction added successfully. Total transactions: ${transactions.length}');
      }else{
        print('TransactionController: Failed to add transaction');
        errorMessage.value = 'Failed to add transaction';
      }
    }catch(e){
      print('TransactionController: Error in addTransaction: $e');
      errorMessage.value = e.toString();
    }finally{
      isLoading.value = false;
      print('TransactionController: Add transaction completed. Loading: ${isLoading.value}');
    }
  }

  Future<void> deleteTransaction(String transactionId) async{
    try{
      print('TransactionController: Starting to delete transaction: $transactionId');
      isLoading.value = true;
      errorMessage.value = '';
      
      final success = await _service.deleteTransaction(transactionId);
      print('TransactionController: Delete transaction result: $success');
      
      if(success){
        print('TransactionController: Removing transaction from local list');
        transactions.removeWhere((t) => t.transactionId == transactionId);
        print('TransactionController: Transaction deleted successfully. Remaining transactions: ${transactions.length}');
      }else{
        print('TransactionController: Failed to delete transaction');
        errorMessage.value = 'Failed to delete transaction';
      }
    }catch(e){
      print('TransactionController: Error in deleteTransaction: $e');
      errorMessage.value = e.toString();
    }finally{
      isLoading.value = false;
      print('TransactionController: Delete transaction completed. Loading: ${isLoading.value}');
    }
  }
}
