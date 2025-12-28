import 'package:flutter/material.dart';

class ProfileAvatarSection extends StatelessWidget {
  final String? userName;

  const ProfileAvatarSection({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = userName ?? 'M';

    return CircleAvatar(
      radius: 40,
      backgroundColor: theme.colorScheme.primary,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
