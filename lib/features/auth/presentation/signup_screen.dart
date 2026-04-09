import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/core/utils/validators.dart';
import 'package:jalsetu/features/auth/data/auth_provider.dart';
import 'package:jalsetu/features/area/data/area_provider.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _selectedAreaId;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    final email = _emailController.text.trim();
    final isAdmin = ['admin@jalsetu.com', 'waterdept@gmail.com']
        .contains(email.toLowerCase());

    if (!isAdmin && _selectedAreaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an area'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    await ref.read(authNotifierProvider.notifier).signUp(
          name: _nameController.text.trim(),
          email: email,
          password: _passwordController.text,
          areaId: _selectedAreaId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final areasAsync = ref.watch(areasProvider);

    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: 12),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 32),

                  // Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusXLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            validator: Validators.name,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Area dropdown
                          areasAsync.when(
                            data: (areas) => DropdownButtonFormField<String>(
                              initialValue: _selectedAreaId,
                              decoration: const InputDecoration(
                                labelText: 'Select Area',
                                prefixIcon: Icon(Icons.location_on_outlined),
                                helperText: 'Admins do not need to select an area',
                              ),
                              items: areas
                                  .map((area) => DropdownMenuItem(
                                        value: area.areaId,
                                        child: Text(area.name),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedAreaId = value),
                              validator: (value) {
                                final email = _emailController.text.trim();
                                final isAdmin = ['admin@jalsetu.com', 'waterdept@gmail.com']
                                    .contains(email.toLowerCase());
                                if (!isAdmin && value == null) {
                                  return 'Please select an area';
                                }
                                return null;
                              },
                            ),
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => const Text(
                              'Could not load areas (Optional for Admin)',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: Validators.password,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return Validators.password(value);
                            },
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  authState.isLoading ? null : _handleSignup,
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Create Account'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account?',
                                  style:
                                      TextStyle(color: AppTheme.textSecondary)),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('Sign In'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
