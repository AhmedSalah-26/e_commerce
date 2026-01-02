import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog to get wallet phone number from user
class WalletPhoneDialog extends StatefulWidget {
  final String? initialPhone;

  const WalletPhoneDialog({super.key, this.initialPhone});

  /// Show the dialog and return the phone number or null if cancelled
  static Future<String?> show(BuildContext context, {String? initialPhone}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => WalletPhoneDialog(initialPhone: initialPhone),
    );
  }

  @override
  State<WalletPhoneDialog> createState() => _WalletPhoneDialogState();
}

class _WalletPhoneDialogState extends State<WalletPhoneDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialPhone ?? '');
    _isValid = _validatePhone(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _validatePhone(String value) {
    final phone = value.replaceAll(RegExp(r'[^\d]'), '');
    // Egyptian mobile: 01xxxxxxxxx (11 digits)
    return phone.length == 11 && phone.startsWith('01');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isRtl ? 'رقم المحفظة' : 'Wallet Number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl
                  ? 'أدخل رقم الهاتف المسجل في المحفظة الإلكترونية'
                  : 'Enter the phone number registered with your wallet',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              textDirection: ui.TextDirection.ltr,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: InputDecoration(
                hintText: '01xxxxxxxxx',
                hintTextDirection: ui.TextDirection.ltr,
                prefixIcon: Icon(Icons.phone, color: theme.colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isValid = _validatePhone(value);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return isRtl ? 'الرقم مطلوب' : 'Number is required';
                }
                if (!_validatePhone(value)) {
                  return isRtl
                      ? 'أدخل رقم صحيح (01xxxxxxxxx)'
                      : 'Enter valid number (01xxxxxxxxx)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Supported wallets info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isRtl
                          ? 'فودافون كاش • أورانج كاش • اتصالات كاش'
                          : 'Vodafone Cash • Orange Cash • Etisalat Cash',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(
            isRtl ? 'إلغاء' : 'Cancel',
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ),
        ElevatedButton(
          onPressed: _isValid
              ? () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop(_controller.text.trim());
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(isRtl ? 'تأكيد' : 'Confirm'),
        ),
      ],
    );
  }
}
