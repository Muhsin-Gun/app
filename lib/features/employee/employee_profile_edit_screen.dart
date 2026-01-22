import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../core/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_image_widget.dart';
import '../../services/cloudinary_service.dart';

class EmployeeProfileEditScreen extends StatefulWidget {
  const EmployeeProfileEditScreen({super.key});

  @override
  State<EmployeeProfileEditScreen> createState() => _EmployeeProfileEditScreenState();
}

class _EmployeeProfileEditScreenState extends State<EmployeeProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  String? _photoUrl;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  final List<String> _availableSkills = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Landscaping',
    'AC Repair',
    'Appliance Repair',
  ];

  List<String> _selectedSkills = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _photoUrl = user.photoUrl;
      
      // Load skills from metadata if available
      if (user.metadata != null && user.metadata!['skills'] != null) {
        _selectedSkills = List<String>.from(user.metadata!['skills']);
      }
      
      // Load bio from metadata if available
      if (user.metadata != null && user.metadata!['bio'] != null) {
        _bioController.text = user.metadata!['bio'];
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isUploadingImage = true;
        });

        // Upload to Cloudinary
        final cloudinaryService = CloudinaryService();
        final uploadedUrl = await cloudinaryService.uploadImage(
          File(pickedFile.path).readAsBytesSync(),
          'employee_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        if (uploadedUrl != null) {
          setState(() {
            _photoUrl = uploadedUrl;
            _isUploadingImage = false;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload image'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() {
            _selectedImage = null;
            _isUploadingImage = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      
      final success = await authProvider.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        photoUrl: _photoUrl,
      );

      if (success && mounted) {
        // Save additional metadata
        await authProvider.updateUserProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          photoUrl: _photoUrl,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Photo Section
              SizedBox(height: 2.h),
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : CustomImageWidget(
                              imageUrl: _photoUrl ?? '',
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'person',
                                    color: theme.colorScheme.primary,
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (_isUploadingImage)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const CustomIconWidget(
                          iconName: 'camera_alt',
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Basic Information
              Text(
                'Basic Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 2.h),

              TextFormField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'Email cannot be changed',
                ),
              ),

              SizedBox(height: 2.h),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),

              SizedBox(height: 2.h),

              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.info),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Tell clients about your experience and expertise',
                  alignLabelWithHint: true,
                ),
              ),

              SizedBox(height: 4.h),

              // Skills Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Skills & Services',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: _availableSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
