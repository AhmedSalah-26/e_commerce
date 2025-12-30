import 'package:flutter/material.dart';

class AnimatedOrderButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final double height;

  const AnimatedOrderButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.height = 56,
  });

  @override
  State<AnimatedOrderButton> createState() => _AnimatedOrderButtonState();
}

class _AnimatedOrderButtonState extends State<AnimatedOrderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Start subtle pulse animation
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = widget.color ?? theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? _scaleAnimation.value : _pulseAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              if (!widget.isLoading && widget.onPressed != null) {
                widget.onPressed!();
              }
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isLoading
                      ? [
                          buttonColor.withValues(alpha: 0.6),
                          buttonColor.withValues(alpha: 0.4),
                        ]
                      : [
                          buttonColor,
                          buttonColor.withValues(alpha: 0.85),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withValues(alpha: 0.4),
                    blurRadius: _isPressed ? 4 : 12,
                    offset: Offset(0, _isPressed ? 2 : 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: null, // Handled by GestureDetector
                  child: Center(
                    child: widget.isLoading
                        ? _buildLoadingIndicator()
                        : _buildLabel(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'جاري التحميل...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.shopping_cart_checkout,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
