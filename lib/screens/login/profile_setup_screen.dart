import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quick_med/custom_components/brand_curved_header.dart';
import 'package:quick_med/custom_components/primary_button.dart';
import 'package:quick_med/screens/login/logo_widget.dart';
import 'package:quick_med/services/auth_service.dart';
import 'package:quick_med/blocs/profile_cubit/profile_cubit.dart';
import 'package:quick_med/blocs/profile_cubit/profile_state.dart';
import 'package:quick_med/services/profile_service.dart';
import 'package:quick_med/services/app_colors.dart';
import 'package:quick_med/services/app_text_styles.dart';
import 'package:quick_med/utils/screen_size.dart';
import 'package:quick_med/constants/kota_areas.dart';
import 'package:quick_med/custom_components/custom_text_field.dart';
import 'package:quick_med/custom_components/delivery_location_picker.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProfileCubit();
        final userId = AuthService.currentUserId;
        if (userId != null) {
          cubit.loadProfile(userId);
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
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  String? _selectedKotaArea;
  String _preservedEmail = '';
  double? _addressLatitude;
  double? _addressLongitude;
  String? _locationValidationError;

  @override
  void initState() {
    super.initState();
    _phoneController.text = AuthService.currentUserPhone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    final hasCoords = _addressLatitude != null && _addressLongitude != null;
    setState(() {
      _locationValidationError =
          hasCoords ? null : 'Pin your delivery location on the map to continue.';
    });
    if (_formKey.currentState!.validate() && hasCoords) {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.')),
        );
        context.go('/login');
        return;
      }

      final profile = UserProfile(
        id: userId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _preservedEmail,
        kotaArea: _selectedKotaArea ?? '',
        addressDetail: _addressController.text.trim(),
        addressLatitude: _addressLatitude,
        addressLongitude: _addressLongitude,
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
          _preservedEmail = state.profile.email;
          if (_phoneController.text.isEmpty) {
            _phoneController.text = state.profile.phone.isNotEmpty 
                ? state.profile.phone 
                : (AuthService.currentUserPhone ?? '');
          }
          if (_addressController.text.isEmpty) {
            _addressController.text = state.profile.addressDetail;
          }
          if (_selectedKotaArea == null && kotaAreas.contains(state.profile.kotaArea)) {
            setState(() {
              _selectedKotaArea = state.profile.kotaArea;
            });
          }
          if (_addressLatitude == null && state.profile.hasDeliveryCoordinates) {
            setState(() {
              _addressLatitude = state.profile.addressLatitude;
              _addressLongitude = state.profile.addressLongitude;
            });
          }
        } else if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile saved successfully! Welcome to QuickMed.'),
              backgroundColor: AppColors.brandGreen,
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
        final isSaving = state is ProfileUpdating;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Column(
            children: [
              const BrandCurvedHeader(heightFactor: 0.18),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: context.fs(20)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: context.sh * 0.02),
                          const Center(
                            child: LogoWidget(
                              widthFactor: 0.22,
                              showTagline: false,
                            ),
                          ),
                          SizedBox(height: context.fs(16)),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(context.fs(24)),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.circular(context.fs(28)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryNavy
                                      .withValues(alpha: 0.10),
                                  offset: const Offset(0, 8),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Complete profile',
                                  style: AppTextStyles.title(context),
                                ),
                                SizedBox(height: context.fs(8)),
                                Text(
                                  'Tell us a bit about yourself for fast delivery in Kota',
                                  style: AppTextStyles.body(context).copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: context.fs(24)),
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
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
                          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textSecondary),
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
                              color: AppColors.textSecondary,
                              fontSize: context.fs(14),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.textSecondary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            filled: true,
                            fillColor: AppColors.inputFill,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: AppColors.inputBorder,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: AppColors.brandTeal,
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
                          items: kotaAreas.map((area) {
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
                          dropdownColor: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        SizedBox(height: context.sh * 0.02),

                        // Address Detail Input
                        CustomTextField(
                          controller: _addressController,
                          labelText: 'Delivery Address Detail',
                          hintText: 'Flat/Street/Landmark',
                          maxLines: 3,
                          prefixIcon: const Icon(Icons.home_outlined, color: AppColors.textSecondary),
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
                        SizedBox(height: context.sh * 0.02),
                        DeliveryLocationPicker(
                          latitude: _addressLatitude,
                          longitude: _addressLongitude,
                          errorText: _locationValidationError,
                          onLocationChanged: (latLng) {
                            setState(() {
                              _addressLatitude = latLng.latitude;
                              _addressLongitude = latLng.longitude;
                              _locationValidationError = null;
                            });
                          },
                        ),
                                SizedBox(height: context.fs(24)),
                                PrimaryButton(
                                  label: isSaving
                                      ? 'Saving...'
                                      : 'Save & Continue',
                                  enabled: !isSaving,
                                  onTap: isSaving ? null : () => _onSave(context),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: context.fs(24)),
                        ],
                      ),
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
