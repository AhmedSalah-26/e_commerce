import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class ProductFormActions extends StatelessWidget {
  final bool isRtl;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const ProductFormActions({
    super.key,
    required this.isRtl,
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              child: Text(isRtl ? 'إلغاء' : 'Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColours.primary,
                foregroundColor: Colors.white,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isRtl ? 'حفظ' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}
