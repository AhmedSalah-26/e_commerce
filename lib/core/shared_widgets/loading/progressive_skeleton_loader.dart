import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProgressiveSkeletonLoader extends StatefulWidget {
  final int itemCount;
  final Duration staggerDuration;
  final Widget Function(int index) itemBuilder;
  final EdgeInsets? padding;
  final double spacing;

  const ProgressiveSkeletonLoader({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDuration = const Duration(milliseconds: 100),
    this.padding,
    this.spacing = 8.0,
  });

  @override
  State<ProgressiveSkeletonLoader> createState() =>
      _ProgressiveSkeletonLoaderState();
}

class _ProgressiveSkeletonLoaderState extends State<ProgressiveSkeletonLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startStaggeredAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.itemCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOut)))
        .toList();
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.staggerDuration * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        children: List.generate(widget.itemCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - _animations[index].value)),
                child: Opacity(
                  opacity: _animations[index].value,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: widget.spacing),
                    child: widget.itemBuilder(index),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class ShimmerImageLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerImageLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class PaginationLoadingIndicator extends StatelessWidget {
  final bool isLoading;
  final String? message;

  const PaginationLoadingIndicator({
    super.key,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          if (message != null) ...[
            const SizedBox(width: 12),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
