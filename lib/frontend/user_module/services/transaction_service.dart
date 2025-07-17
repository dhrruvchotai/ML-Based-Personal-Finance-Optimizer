import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

class TransactionService{
  static const String baseUrl = '';

  //fetch transaction from userId
  Future<List<TransactionModel>> fetchTransactionsByUser(String userId) async {
    final url = Uri.parse('$baseUrl/transactions/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => TransactionModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  //add transaction
  Future<bool> addTransaction(TransactionModel transaction) async {
    final url = Uri.parse('$baseUrl/transactions');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transaction.toJson()),
    );

    return response.statusCode == 201;
  }

  //delete transaction of a user
  Future<bool> deleteTransaction(String transactionId) async {
    final url = Uri.parse('$baseUrl/transactions/$transactionId');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}
