import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/core/utils/validators.dart';
import 'package:jalsetu/features/auth/data/auth_provider.dart';
import 'package:jalsetu/features/complaints/data/complaint_repository.dart';
import 'package:jalsetu/features/complaints/data/complaint_provider.dart';
import 'package:jalsetu/shared/models/complaint_model.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jalsetu/core/services/notification_service.dart';


class ComplaintFormScreen extends ConsumerStatefulWidget {
  const ComplaintFormScreen({super.key});

  @override
  ConsumerState<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends ConsumerState<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'No Water Supply';
  bool _isSubmitting = false;

  static const List<String> categories = [
    'No Water Supply',
    'Low Pressure',
    'Water Leakage',
    'Contaminated Water',
    'Pipeline Issue',
    'Billing Issue',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) return;

      final priority =
          PriorityHelper.calculatePriority(_descriptionController.text);
      final complaintId =
          FirebaseFirestore.instance.collection('complaints').doc().id;
      final complaint = Complaint(
        complaintId: complaintId,
        userId: user.userId,
        areaId: user.areaId ?? '',
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        status: 'pending',
        priority: priority,
        createdAt: DateTime.now(),
      );

      await ComplaintRepository().createComplaint(complaint);
      ref.invalidate(userComplaintsProvider);

      ref.read(notificationServiceProvider).showNotification(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: 'Complaint Submitted',
        body: 'Your complaint regarding $_selectedCategory has been received.',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint submitted successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'New Complaint', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category
              Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categories
                    .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                validator: Validators.description,
                decoration: const InputDecoration(
                  hintText:
                      'Describe your issue in detail...\n(e.g., no water supply since morning)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),

              // Priority hint
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                      color: AppTheme.warningOrange.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppTheme.warningOrange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Priority is auto-assigned based on keywords like "no water", "leak", "contamination".',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Complaint'),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),
      ),
    );
  }
}
