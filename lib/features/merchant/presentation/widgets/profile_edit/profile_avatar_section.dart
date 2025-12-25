import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class ProfileAvatarSection extends StatelessWidget {
  final String? userName;

  const ProfileAvatarSection({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = userName ?? 'M';

    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColours.brownLight,
      child: Text(
        displayName[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
