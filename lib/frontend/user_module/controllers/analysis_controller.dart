import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/pdf_service.dart';
import '../services/stock_market_service.dart';

class AnalysisController extends GetxController {
  final TransactionService _service = TransactionService();
  final StockMarketService _stockMarketService = StockMarketService(); // Add stock market service
  
  var transactions = <TransactionModel>[].obs;
  var filteredTransactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isGeneratingPdf = false.obs;
  
  // New properties for stock market data
  final isLoadingMarketData = true.obs;
  final marketDataError = ''.obs;
  final marketIndices = <String, dynamic>{}.obs;
  final topGainers = <Map<String, dynamic>>[].obs;

  // Chart screenshot keys
  final GlobalKey expenseChartKey = GlobalKey();
  final GlobalKey incomeChartKey = GlobalKey();
  
  @override
  void onInit() {
    super.onInit();
    loadUserIdAndFetchTransactions();
    fetchMarketData(); // Add this to fetch market data on init
  }
  
  Future<void> loadUserIdAndFetchTransactions() async {
    try {
      // Get userId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId != null && userId.isNotEmpty) {
        await fetchTransactions(userId);
      } else {
        // Fallback to default user ID if needed
        await fetchTransactions('687a5088ef80ce4d11f829aa');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user data: $e';
    }
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
  
  // Take a screenshot of a widget using its GlobalKey
  Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final RenderRepaintBoundary boundary = 
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = 
          await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing widget: $e');
      return null;
    }
  }
  
  // Generate and download PDF report
  Future<void> generatePdfReport() async {
    try {
      isGeneratingPdf.value = true;
      Get.snackbar(
        'Generating Report',
        'Please wait while we prepare your financial report...',
        duration: const Duration(seconds: 2),
      );
      
      // Capture chart screenshots if keys are attached to widgets
      Uint8List? expenseChartImage;
      Uint8List? incomeChartImage;
      
      try {
        expenseChartImage = await captureWidget(expenseChartKey);
        incomeChartImage = await captureWidget(incomeChartKey);
      } catch (e) {
        print('Error capturing charts: $e');
        // Continue without chart images
      }
      
      // Get user name (or fallback to default)
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      String userName = 'User';
      
      if (userData != null) {
        try {
          // Try to parse user data for name
          final userDataMap = jsonDecode(userData) as Map<String, dynamic>;
          userName = userDataMap['username'] ?? 'User';
        } catch (e) {
          print('Error parsing user data: $e');
          // Continue with default name
        }
      }
      
      // Generate PDF report
      final pdfFile = await PdfService.generateFinancialReport(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        netAmount: netAmount,
        expenseData: getExpenseData(),
        incomeData: getIncomeData(),
        userName: userName,
        expenseChartImage: expenseChartImage,
        incomeChartImage: incomeChartImage,
      );
      
      // Open the generated PDF
      await PdfService.openPDF(pdfFile);
      
      Get.snackbar(
        'Report Generated',
        'Your financial report has been generated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error generating PDF report: $e');
      Get.snackbar(
        'Error',
        'Failed to generate report: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  // New method to fetch market data
  Future<void> fetchMarketData() async {
    isLoadingMarketData.value = true;
    marketDataError.value = '';
    
    try {
      // Fetch market indices
      final indicesData = await _stockMarketService.getMarketIndices();
      marketIndices.value = indicesData['indices'] ?? {};
      
      // Fetch top gainers
      final gainersData = await _stockMarketService.getTopGainers();
      topGainers.value = (gainersData['gainers'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      
    } catch (e) {
      marketDataError.value = 'Failed to load market data: ${e.toString()}';
    } finally {
      isLoadingMarketData.value = false;
    }
  }

  // Add this method to refresh market data
  void refreshMarketData() {
    fetchMarketData();
  }
} 