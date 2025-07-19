import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../models/user_model.dart';

class UserProfileController extends GetxController {
  // Form controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  
  // Image state
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString profileImagePath = ''.obs;
  
  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;
  
  // User data
  final Rx<UserModel> user = UserModel().obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }
  
  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
  
  // Load user data from shared preferences
  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      
      if (userData != null) {
        user.value = UserModel.fromJsonString(userData);
        
        // Set the text controllers
        usernameController.text = user.value.username ?? '';
        emailController.text = user.value.email ?? '';
        phoneController.text = user.value.phoneNumber ?? '';
        
        // Set profile image path if it exists
        if (user.value.profileImagePath != null && 
            user.value.profileImagePath!.isNotEmpty &&
            File(user.value.profileImagePath!).existsSync()) {
          profileImagePath.value = user.value.profileImagePath!;
          selectedImage.value = File(profileImagePath.value);
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Save user data to shared preferences
  Future<void> saveUserData() async {
    isLoading.value = true;
    try {
      // Update user model with form values
      user.value = user.value.copyWith(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        profileImagePath: profileImagePath.value,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', user.value.toJsonString());
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      isEditing.value = false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Error saving user data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Pick image from gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        // Save the image to app documents directory
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String filePath = '${appDocDir.path}/$fileName';
        
        // Copy the selected image to app directory
        await File(image.path).copy(filePath);
        
        // Update state
        selectedImage.value = File(filePath);
        profileImagePath.value = filePath;
        
        // Update user model
        user.value = user.value.copyWith(profileImagePath: filePath);
        
        // Save to shared preferences
        saveUserData();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      debugPrint('Error picking image: $e');
    }
  }
  
  // Toggle editing mode
  void toggleEditingMode() {
    isEditing.value = !isEditing.value;
    
    if (!isEditing.value) {
      // If cancelling edit, restore values from user model
      usernameController.text = user.value.username ?? '';
      emailController.text = user.value.email ?? '';
      phoneController.text = user.value.phoneNumber ?? '';
    }
  }
  
  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }
  
  // Phone number validation
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
} 