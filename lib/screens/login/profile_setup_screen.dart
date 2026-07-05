import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quick_med/blocs/profile_cubit/profile_cubit.dart';
import 'package:quick_med/blocs/profile_cubit/profile_state.dart';
import 'package:quick_med/services/profile_service.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';
import 'package:quick_med/custom_components/custom_text_field.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProfileCubit();
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          cubit.loadProfile(user.id);
        }
        return cubit;
      },
      child: const ProfileSetupView(),
    );
  }
}

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedKotaArea;

  final List<String> _kotaAreas = [
    'Nayapura',
    'Talwandi',
    'Kunhari',
    'Landmark City',
    'Vigyan Nagar',
    'Gumanpura',
    'Dadabari',
    'Mahaveer Nagar',
    'Rajeev Gandhi Nagar',
    'Shrinath Puram',
  ];

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.')),
        );
        context.go('/login');
        return;
      }

      final profile = UserProfile(
        id: user.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        kotaArea: _selectedKotaArea ?? '',
        addressDetail: _addressController.text.trim(),
      );

      context.read<ProfileCubit>().saveProfile(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // If we loaded existing profile data, prefill
          if (_nameController.text.isEmpty) {
            _nameController.text = state.profile.name;
          }
          if (_emailController.text.isEmpty) {
            _emailController.text = state.profile.email.isNotEmpty 
                ? state.profile.email 
                : (Supabase.instance.client.auth.currentUser?.email ?? '');
          }
          if (_phoneController.text.isEmpty) {
            _phoneController.text = state.profile.phone.isNotEmpty 
                ? state.profile.phone 
                : (Supabase.instance.client.auth.currentUser?.phone ?? '');
          }
          if (_addressController.text.isEmpty) {
            _addressController.text = state.profile.addressDetail;
          }
          if (_selectedKotaArea == null && _kotaAreas.contains(state.profile.kotaArea)) {
            setState(() {
              _selectedKotaArea = state.profile.kotaArea;
            });
          }
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully! Welcome to QuickMed.'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/home_screen');
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              // 1. Watermark Background Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.08,
                  child: Image.asset(
                    'assets/images/watermark-pattern.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 2. Main Content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: context.sh * 0.04),
                        
                        // Icon Header
                        Center(
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: context.sh * 0.02),

                        // Title
                        Text(
                          'Complete Profile',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tell us a bit about yourself to get fast delivery in Kota',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: context.sh * 0.04),

                        // Email Input (Disabled/Read-only from active session)
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'Email address',
                          enabled: false,
                          prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF9CA3AF)),
                        ),
                        SizedBox(height: context.sh * 0.02),

                        // Full Name Input
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6B7280)),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: context.sh * 0.02),

                        // Phone Number Input (Editable)
                        CustomTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          hintText: 'Enter your 10-digit phone number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF6B7280)),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.trim().length < 10) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: context.sh * 0.02),

                        // Kota Area Dropdown
                        DropdownButtonFormField<String>(
                          initialValue: _selectedKotaArea,
                          hint: Text('Select Area in Kota', style: AppTextStyles.hintText(context)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your area in Kota';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Kota Area',
                            labelStyle: TextStyle(
                              color: const Color(0xFF6B7280),
                              fontSize: context.fs(14),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: const Icon(Icons.location_city_outlined, color: Color(0xFF6B7280)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            filled: true,
                            fillColor: AppColors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                                width: 1.5,
                              ),
                            ),
                          ),
                          items: _kotaAreas.map((area) {
                            return DropdownMenuItem<String>(
                              value: area,
                              child: Text(
                                area,
                                style: AppTextStyles.inputText(context),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKotaArea = value;
                            });
                          },
                          dropdownColor: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        SizedBox(height: context.sh * 0.02),

                        // Address Detail Input
                        CustomTextField(
                          controller: _addressController,
                          labelText: 'Delivery Address Detail',
                          hintText: 'Flat/Street/Landmark',
                          maxLines: 3,
                          prefixIcon: const Icon(Icons.home_outlined, color: Color(0xFF6B7280)),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your detailed delivery address';
                            }
                            if (value.trim().length < 5) {
                              return 'Address must be at least 5 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: context.sh * 0.05),

                        // Save Button
                        GestureDetector(
                          onTap: state is ProfileUpdating ? null : () => _onSave(context),
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  offset: const Offset(0, 8),
                                  blurRadius: 15,
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: state is ProfileUpdating
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                    ),
                                  )
                                : Text(
                                    'Save & Continue',
                                    style: AppTextStyles.buttonText(context),
                                  ),
                          ),
                        ),
                        SizedBox(height: context.sh * 0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
