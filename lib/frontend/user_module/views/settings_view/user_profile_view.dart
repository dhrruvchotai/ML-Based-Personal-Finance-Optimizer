import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_profile_controller.dart';

class UserProfileView extends StatelessWidget {
  UserProfileView({Key? key}) : super(key: key);

  final UserProfileController controller = Get.put(UserProfileController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Obx(() => controller.isEditing.value
              ? IconButton(
                  icon: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.saveUserData();
                    }
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: controller.toggleEditingMode,
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.chat),onPressed:() {
        Get.toNamed('/chatbot');
      },),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                _buildProfileImageSection(context),
                const SizedBox(height: 30),
                
                // Profile Details Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Username Field
                        _buildTextField(
                          controller: controller.usernameController,
                          label: 'Username',
                          icon: Icons.person,
                          enabled: controller.isEditing.value,
                          context: context,
                        ),
                        const SizedBox(height: 16),
                        
                        // Email Field
                        _buildTextField(
                          controller: controller.emailController,
                          label: 'Email',
                          icon: Icons.email,
                          enabled: controller.isEditing.value,
                          context: context,
                          validator: controller.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone Field
                        _buildTextField(
                          controller: controller.phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone,
                          enabled: controller.isEditing.value,
                          context: context,
                          validator: controller.validatePhone,
                          keyboardType: TextInputType.phone,
                        ),
                        
                        // Account Status
                        Obx(() => controller.user.value.isBlocked != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    controller.user.value.isBlocked! 
                                      ? Icons.block 
                                      : Icons.check_circle,
                                    color: controller.user.value.isBlocked! 
                                      ? Colors.red 
                                      : Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Account Status: ${controller.user.value.isBlocked! ? 'Blocked' : 'Active'}',
                                    style: TextStyle(
                                      color: controller.user.value.isBlocked! 
                                        ? Colors.red 
                                        : Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink()),
                        
                        // Account Creation Date
                        Obx(() => controller.user.value.createdAt != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Account Created: ${_formatDate(controller.user.value.createdAt!)}',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Edit/Save Button
                if (controller.isEditing.value)
                  TextButton(
                    onPressed: controller.toggleEditingMode,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Profile Image Section
  Widget _buildProfileImageSection(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return Stack(
            children: [
              // Profile Image
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: controller.selectedImage.value != null
                      ? Image.file(
                          controller.selectedImage.value!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                ),
              ),
              // Edit Image Button
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: controller.pickImage,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.background,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 12),
        Obx(() => Text(
          controller.user.value.username ?? 'Set your username',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        )),
        const SizedBox(height: 4),
        Obx(() => Text(
          controller.user.value.email ?? 'Add your email',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        )),
      ],
    );
  }

  // Text Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    required BuildContext context,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
    );
  }
  
  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
