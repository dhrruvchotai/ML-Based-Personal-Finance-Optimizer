import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../models/goal_model.dart';
import '../services/goal_service.dart';

class GoalController extends GetxController {
  final GoalService _goalService = GoalService();
  final formKey = GlobalKey<FormState>();
  
  // Form controllers
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final depositAmountController = TextEditingController();
  final withdrawAmountController = TextEditingController();
  
  // Selected dates
  Rx<DateTime> selectedStartDate = DateTime.now().obs;
  Rx<DateTime> selectedEndDate = DateTime.now().add(const Duration(days: 30)).obs;
  
  // Observable variables
  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var goals = <Goal>[].obs;
  var errorMessage = ''.obs;
  var userId = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserId();
  }
  
  @override
  void onClose() {
    titleController.dispose();
    amountController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    descriptionController.dispose();
    depositAmountController.dispose();
    withdrawAmountController.dispose();
    super.onClose();
  }
  
  // Load user ID from shared preferences
  Future<void> loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      
      if (storedUserId != null && storedUserId.isNotEmpty) {
        userId.value = storedUserId;
        fetchGoals();
      } else {
        // Fallback to default user ID if needed
        userId.value = '687a5088ef80ce4d11f829aa'; // Replace with your default user ID
        fetchGoals();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user data: $e';
    }
  }
  
  // Fetch all goals for the current user
  Future<void> fetchGoals() async {
    if (userId.value.isEmpty) {
      errorMessage.value = 'User ID is not available';
      return;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final fetchedGoals = await _goalService.getGoals(userId.value);
      goals.value = fetchedGoals;
    } catch (e) {
      errorMessage.value = 'Failed to load goals: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Add a new goal
  Future<void> addGoal() async {
    if (!formKey.currentState!.validate()) return;
    
    try {
      isSubmitting.value = true;
      errorMessage.value = '';
      
      final newGoal = Goal(
        userId: userId.value,
        title: titleController.text.trim(),
        targetAmount: double.parse(amountController.text.trim()),
        startDate: selectedStartDate.value,
        endDate: selectedEndDate.value,
        description: descriptionController.text.trim(),
      );
      
      print("Attempting to add goal with userId: ${userId.value}");
      print("Goal data: ${newGoal.toJson()}");
      
      await _goalService.addGoal(newGoal);
      clearForm();
      Get.back(); // Close the add goal dialog/screen
      fetchGoals(); // Refresh the goals list
      
      Get.snackbar(
        'Success',
        'Goal added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error adding goal: $e");
      errorMessage.value = 'Failed to add goal: $e';
      Get.snackbar(
        'Error',
        'Failed to add goal: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSubmitting.value = false;
    }
  }
  
  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    try {
      await _goalService.deleteGoal(goalId);
      fetchGoals(); // Refresh the goals list
      
      Get.snackbar(
        'Success',
        'Goal deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete goal: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Deposit money to a goal
  Future<void> depositToGoal(String goalId, double amount) async {
    try {
      await _goalService.depositToGoal(goalId, amount);
      depositAmountController.clear();
      fetchGoals(); // Refresh the goals list
      
      Get.snackbar(
        'Success',
        'Deposit successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to make deposit: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Withdraw money from a goal
  Future<void> withdrawFromGoal(String goalId, double amount) async {
    try {
      await _goalService.withdrawFromGoal(goalId, amount);
      withdrawAmountController.clear();
      fetchGoals(); // Refresh the goals list
      
      Get.snackbar(
        'Success',
        'Withdrawal successful',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to withdraw: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // Select start date
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != selectedStartDate.value) {
      selectedStartDate.value = picked;
      startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }
  
  // Select end date
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != selectedEndDate.value) {
      selectedEndDate.value = picked;
      endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }
  
  // Clear form fields
  void clearForm() {
    titleController.clear();
    amountController.clear();
    descriptionController.clear();
    
    selectedStartDate.value = DateTime.now();
    startDateController.text = DateFormat('dd/MM/yyyy').format(selectedStartDate.value);
    
    selectedEndDate.value = DateTime.now().add(const Duration(days: 30));
    endDateController.text = DateFormat('dd/MM/yyyy').format(selectedEndDate.value);
  }
  
  // Initialize form fields
  void initializeForm() {
    startDateController.text = DateFormat('dd/MM/yyyy').format(selectedStartDate.value);
    endDateController.text = DateFormat('dd/MM/yyyy').format(selectedEndDate.value);
  }
} 