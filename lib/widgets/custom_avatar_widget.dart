import 'package:flutter/material.dart';

class CustomAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? semanticLabel;

  const CustomAvatarWidget({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
            ? NetworkImage(imageUrl!)
            : null,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(Icons.person, size: radius)
            : null,
      ),
    );
  }
}
