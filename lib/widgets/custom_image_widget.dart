import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/app_config.dart';

class CustomImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String semanticLabel;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    required this.semanticLabel,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    Widget imageWidget;

    if (imageUrl.startsWith('http')) {
      // Network image
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) {
          AppConfig.logError('Failed to load image: $url', error);
          return _buildErrorWidget(context);
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      );
    } else if (imageUrl.startsWith('assets/')) {
      // Asset image
      imageWidget = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        errorBuilder: (context, error, stackTrace) {
          AppConfig.logError('Failed to load asset image: $imageUrl', error);
          return _buildErrorWidget(context);
        },
      );
    } else {
      // Invalid URL
      return _buildErrorWidget(context);
    }

    // Wrap with container if background color or border radius is specified
    if (backgroundColor != null || borderRadius != null) {
      imageWidget = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        clipBehavior: borderRadius != null ? Clip.antiAlias : Clip.none,
        child: imageWidget,
      );
    }

    return Semantics(
      label: semanticLabel,
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.broken_image,
          color: Theme.of(context).colorScheme.onErrorContainer,
          size: (width != null && height != null) 
              ? (width! < height! ? width! * 0.4 : height! * 0.4)
              : 24,
        ),
      ),
    );
  }
}

// Circular avatar image widget
class CustomAvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String fallbackText;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const CustomAvatarWidget({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.radius = 25,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        child: ClipOval(
          child: CustomImageWidget(
            imageUrl: imageUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            semanticLabel: 'Profile picture of $fallbackText',
            errorWidget: _buildFallbackAvatar(context),
          ),
        ),
      );
    } else {
      avatar = _buildFallbackAvatar(context);
    }

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      child: Text(
        _getInitials(fallbackText),
        style: TextStyle(
          color: textColor ?? Theme.of(context).colorScheme.onPrimary,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String text) {
    if (text.isEmpty) return '?';
    
    final words = text.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return text[0].toUpperCase();
  }
}

// Image picker widget
class ImagePickerWidget extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;
  final double size;
  final String label;

  const ImagePickerWidget({
    super.key,
    this.imageUrl,
    required this.onTap,
    this.size = 120,
    this.label = 'Add Image',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomImageWidget(
                  imageUrl: imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  semanticLabel: 'Selected image',
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: size * 0.3,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

// Image gallery widget
class ImageGalleryWidget extends StatelessWidget {
  final List<String> imageUrls;
  final double itemHeight;
  final int crossAxisCount;
  final Function(int index)? onImageTap;

  const ImageGalleryWidget({
    super.key,
    required this.imageUrls,
    this.itemHeight = 120,
    this.crossAxisCount = 3,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Container(
        height: itemHeight,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No images available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onImageTap?.call(index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageWidget(
              imageUrl: imageUrls[index],
              fit: BoxFit.cover,
              semanticLabel: 'Gallery image ${index + 1}',
            ),
          ),
        );
      },
    );
  }
}
