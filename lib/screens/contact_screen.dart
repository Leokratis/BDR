import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/api_response.dart';
import '../theme/app_theme.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _captchaController = TextEditingController();

  CaptchaData? _captchaData;
  bool _isLoadingCaptcha = false;
  bool _isSubmitting = false;
  String? _submitError;
  bool _submitSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadCaptcha();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  Future<void> _loadCaptcha() async {
    setState(() {
      _isLoadingCaptcha = true;
    });

    try {
      final captcha = await ApiService.getCaptcha();
      setState(() {
        _captchaData = captcha;
        _isLoadingCaptcha = false;
        _captchaController.clear();
      });
    } catch (e) {
      setState(() {
        _isLoadingCaptcha = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load captcha: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_captchaData == null) {
      setState(() {
        _submitError = 'Please load captcha first';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
      _submitSuccess = false;
    });

    try {
      final issue = ContactIssue(
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        captchaId: _captchaData!.id,
        captchaAnswer: _captchaController.text.trim(),
      );

      await ApiService.sendIssue(issue);

      setState(() {
        _isSubmitting = false;
        _submitSuccess = true;
      });

      // Clear the form
      _formKey.currentState!.reset();
      _emailController.clear();
      _phoneController.clear();
      _subjectController.clear();
      _messageController.clear();
      _captchaController.clear();
      
      // Load new captcha
      _loadCaptcha();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message sent successfully!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _submitError = e.toString();
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to our support team',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Contact Information
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                hintText: 'your.email@example.com',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if ((value == null || value.trim().isEmpty) &&
                                    _phoneController.text.trim().isEmpty) {
                                  return 'Email or phone number is required';
                                }
                                if (value != null && value.trim().isNotEmpty) {
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                    return 'Please enter a valid email address';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                hintText: '+30 123 456 7890',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if ((value == null || value.trim().isEmpty) &&
                                    _emailController.text.trim().isEmpty) {
                                  return 'Email or phone number is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Message Details
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Message Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _subjectController,
                              decoration: const InputDecoration(
                                labelText: 'Subject',
                                hintText: 'Brief description of your issue',
                                prefixIcon: Icon(Icons.subject),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Subject is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                labelText: 'Message',
                                hintText: 'Describe your issue in detail...',
                                prefixIcon: Icon(Icons.message),
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Message is required';
                                }
                                if (value.trim().length < 10) {
                                  return 'Message must be at least 10 characters long';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Captcha
                      CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Security Verification',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _isLoadingCaptcha ? null : _loadCaptcha,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Refresh'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_isLoadingCaptcha)
                              const Center(
                                child: CircularProgressIndicator(),
                              )
                            else if (_captchaData != null) ...[
                              Container(
                                width: double.infinity,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.outline),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    base64Decode(_captchaData!.image),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _captchaController,
                                decoration: const InputDecoration(
                                  labelText: 'Enter the text shown above',
                                  hintText: 'Type the captcha text',
                                  prefixIcon: Icon(Icons.security),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Captcha is required';
                                  }
                                  return null;
                                },
                              ),
                            ] else
                              Container(
                                width: double.infinity,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.outline),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Text('Failed to load captcha'),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Submit Button
                      if (_submitError != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                          ),
                          child: Text(
                            _submitError!,
                            style: const TextStyle(color: AppTheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Send Message',
                          onPressed: _isSubmitting ? null : _submitForm,
                          isLoading: _isSubmitting,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
