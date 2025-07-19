import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ml_based_personal_finance_optimizer/frontend/user_module/services/auth_services.dart';
import 'package:ml_based_personal_finance_optimizer/frontend/user_module/views/home_page.dart';

import '../../models/auth_model.dart';

class SignUpSignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  AuthService _authService = AuthService();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  AuthModel authModel = AuthModel();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  void signUpUsingEmail(GlobalKey<FormState> formKey) async {
    final SignUpSignInController controller = Get.find<SignUpSignInController>();
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    final user = await authModel.signUpWithEmail(emailController.text, passwordController.text);
    if(user != null){
      //this need to be managed before push
      await _authService.addUser(userName: user.displayName, email: user.email);
      Get.off(HomePage());


      Get.snackbar(
        'Success',
        'Account created successfully!',
        backgroundColor: Get.theme.colorScheme.inversePrimary,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }else{
      Get.snackbar(
        'Error',
        'Account creation failed!',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
    isLoading.value = false;
  }

  void loginWithEmail(GlobalKey<FormState> formKey) async {
    final SignUpSignInController controller = Get.find<SignUpSignInController>();
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    final user = await authModel.loginWithEmail(emailController.text, passwordController.text);
    if(user != null){
      //this need to be managed before push
      Get.off(HomePage());

      Get.snackbar(
        'Success',
        'Email sign in successful!',
        backgroundColor: Get.theme.colorScheme.inversePrimary,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );  
    }else{
      Get.snackbar(
        'Error',
        'Email sign in failed!',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
    // if(authModel != null){
    //   Get.offAllNamed(Routes.HOME);
    // }
    isLoading.value = false;
  }

  void loginUsingGoogle() async {
    isLoading.value = true;
    final user = await authModel.loginWithGoogle();
    if(user != null){
      print("=====================Google Login User : ");
      print(user.user);
      //this need to be managed before push
      Get.off(HomePage());
      Get.snackbar(
      'Success',
      'Google sign in successful!',
      backgroundColor: Get.theme.colorScheme.inversePrimary,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
    }else{
      Get.snackbar(
        'Error',
        'Google sign in failed!',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    }
    isLoading.value = false;
    
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
