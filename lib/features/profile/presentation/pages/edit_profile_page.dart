import 'package:atabei/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:atabei/features/profile/presentation/cubit/profile/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atabei/features/profile/domain/entities/user_profile_entity.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileEntity userProfile;

  const EditProfilePage({
    super.key,
    required this.userProfile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.userProfile.username);
    _bioController = TextEditingController(text: widget.userProfile.bio ?? '');
    _locationController = TextEditingController(text: widget.userProfile.location ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        print("🔔 EditProfile listener - State: ${state.runtimeType}");
        
        if (state is ProfileLoaded) {
          print("🔔 EditProfile - Profile updated successfully!");
          // Profile updated successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Small delay to ensure state is fully processed
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              print("🔔 EditProfile - Navigating back with updated profile");
              Navigator.pop(context, state.userProfile); // Return the updated profile
            }
          });
          
        } else if (state is ProfileError) {
          print("🔔 EditProfile - Error: ${state.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${state.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is ProfileUpdating) {
          print("🔔 EditProfile - Profile is updating...");
        }
      },
      builder: (context, state) {
        print("🔔 EditProfile builder - State: ${state.runtimeType}");
        final isUpdating = state is ProfileUpdating;
        
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: isUpdating ? null : () => Navigator.pop(context),
            ),
            title: const Text(
              'Edit Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: isUpdating ? null : _saveProfile,
                  child: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
          body: AbsorbPointer(
            absorbing: isUpdating,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loading indicator overlay
                    if (isUpdating)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Updating your profile...',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (isUpdating) const SizedBox(height: 16),
                    
                    _buildProfileHeaderInfo(),
                    
                    const SizedBox(height: 32),
                    
                    _buildFormFields(),
                    
                    const SizedBox(height: 32),
                    
                    _buildSaveButton(isUpdating),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.userProfile.username.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userProfile.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Edit your profile information below',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username Field
        _buildTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Enter your username',
          maxLength: 15,
          prefixIcon: Icons.person_outline,
          isRequired: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username is required';
            }
            if (value.trim().length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (value.contains(' ')) {
              return 'Username cannot contain spaces';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 24),
        
        // Bio Field
        _buildTextField(
          controller: _bioController,
          label: 'Bio',
          hint: 'Tell people about yourself',
          maxLength: 160,
          maxLines: 3,
          prefixIcon: Icons.info_outline,
          validator: (value) {
            if (value != null && value.length > 160) {
              return 'Bio must be 160 characters or less';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 24),
        
        // Location Field
        _buildTextField(
          controller: _locationController,
          label: 'Location',
          hint: 'Where are you based?',
          maxLength: 30,
          prefixIcon: Icons.location_on_outlined,
          validator: (value) {
            if (value != null && value.length > 30) {
              return 'Location must be 30 characters or less';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 32),
        
        // Information Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Visibility',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your profile information is public and can be seen by other users.',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            counterText: maxLength != null ? '${controller.text.length}/$maxLength' : null,
          ),
          onChanged: (value) {
            setState(() {}); // Update counter
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isUpdating) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isUpdating ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isUpdating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Saving...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors above'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('🔄 _saveProfile called');
    print('🔄 Current state: ${context.read<ProfileCubit>().state.runtimeType}');

    final updatedProfile = widget.userProfile.copyWith(
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
    );

    print('🔄 About to call updateProfile with: ${updatedProfile.username}');

    try {
      await context.read<ProfileCubit>().updateProfile(updatedProfile);
      print('🔄 updateProfile call completed');
    } catch (e) {
      print('🔄 Error calling updateProfile: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}