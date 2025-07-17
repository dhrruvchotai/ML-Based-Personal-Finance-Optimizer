import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../services/transaction_routs.dart';

class TransactionController extends GetxController{
  final TransactionRouts _service = TransactionRouts();

  var transactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> fetchTransactions(String userId) async{
    try{
      isLoading.value = true;
      errorMessage.value = '';
      final fetched = await _service.fetchTransactionsByUser(userId);
      transactions.assignAll(fetched);
    }catch (e){
      errorMessage.value = e.toString();
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> addTransaction(TransactionModel txn) async{
    try{
      isLoading.value = true;
      errorMessage.value = '';
      final success = await _service.addTransaction(txn);
      if(success){
        transactions.add(txn);
      }else{
        errorMessage.value = 'Failed to add transaction';
      }
    }catch(e){
      errorMessage.value = e.toString();
    }finally{
      isLoading.value = false;
    }
  }

  Future<void> deleteTransaction(String transactionId) async{
    try{
      isLoading.value = true;
      errorMessage.value = '';
      final success = await _service.deleteTransaction(transactionId);
      if(success){
        transactions.removeWhere((t) => t.transactionId == transactionId);
      }else{
        errorMessage.value = 'Failed to delete transaction';
      }
    }catch(e){
      errorMessage.value = e.toString();
    }finally{
      isLoading.value = false;
    }
  }
}
