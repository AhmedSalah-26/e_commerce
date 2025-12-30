import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/shared_widgets/toast.dart';

class CopyableRow extends StatelessWidget {
  final String label;
  final String value;
  final double labelWidth;

  const CopyableRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 80,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(label,
                style: TextStyle(
                    color: textColor.withValues(alpha: 0.7), fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(fontSize: 13, color: textColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            icon: Icon(Icons.copy, size: 16, color: iconColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Tost.showCustomToast(
                context,
                'تم النسخ',
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );
            },
          ),
        ],
      ),
    );
  }
}
