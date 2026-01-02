import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  /// Check if device is tablet
  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  /// Get adaptive padding based on screen size
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
    }
  }

  /// Get adaptive margin based on screen size
  static EdgeInsets getAdaptiveMargin(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(8);
      case DeviceType.tablet:
        return const EdgeInsets.all(12);
      case DeviceType.desktop:
        return const EdgeInsets.all(16);
    }
  }

  /// Get adaptive font size
  static double getAdaptiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile * 1.1;
      case DeviceType.desktop:
        return desktop ?? mobile * 1.2;
    }
  }

  /// Get grid column count based on screen size
  static int getGridColumns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Get adaptive spacing
  static double getAdaptiveSpacing(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 8.0;
      case DeviceType.tablet:
        return 12.0;
      case DeviceType.desktop:
        return 16.0;
    }
  }

  /// Get adaptive card elevation
  static double getAdaptiveElevation(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 2.0;
      case DeviceType.tablet:
        return 4.0;
      case DeviceType.desktop:
        return 6.0;
    }
  }

  /// Get adaptive border radius
  static BorderRadius getAdaptiveBorderRadius(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return BorderRadius.circular(8);
      case DeviceType.tablet:
        return BorderRadius.circular(12);
      case DeviceType.desktop:
        return BorderRadius.circular(16);
    }
  }

  /// Get adaptive icon size
  static double getAdaptiveIconSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 24.0;
      case DeviceType.tablet:
        return 28.0;
      case DeviceType.desktop:
        return 32.0;
    }
  }

  /// Get adaptive button height
  static double getAdaptiveButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 48.0;
      case DeviceType.tablet:
        return 52.0;
      case DeviceType.desktop:
        return 56.0;
    }
  }

  /// Get adaptive app bar height
  static double getAdaptiveAppBarHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return kToolbarHeight;
      case DeviceType.tablet:
        return kToolbarHeight + 8;
      case DeviceType.desktop:
        return kToolbarHeight + 16;
    }
  }

  /// Check if should use drawer or sidebar
  static bool shouldUseDrawer(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Get adaptive max width for content
  static double getAdaptiveMaxWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 800;
      case DeviceType.desktop:
        return 1200;
    }
  }

  /// Get adaptive dialog width
  static double getAdaptiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth * 0.9;
      case DeviceType.tablet:
        return screenWidth * 0.7;
      case DeviceType.desktop:
        return screenWidth * 0.5;
    }
  }

  /// Get adaptive bottom sheet height
  static double getAdaptiveBottomSheetHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return screenHeight * 0.9;
      case DeviceType.tablet:
        return screenHeight * 0.8;
      case DeviceType.desktop:
        return screenHeight * 0.7;
    }
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    return builder(context, deviceType);
  }
}

class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? color;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ResponsiveHelper.getAdaptivePadding(context),
      margin: margin ?? ResponsiveHelper.getAdaptiveMargin(context),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            borderRadius ?? ResponsiveHelper.getAdaptiveBorderRadius(context),
        boxShadow: elevation != null
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: elevation!,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing = 8.0,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getGridColumns(
      context,
      mobile: mobileColumns ?? 2,
      tablet: tabletColumns ?? 3,
      desktop: desktopColumns ?? 4,
    );

    return GridView.builder(
      padding: padding ?? ResponsiveHelper.getAdaptivePadding(context),
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.8,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

class AdaptiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AdaptiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final adaptiveFontSize = mobileFontSize != null
        ? ResponsiveHelper.getAdaptiveFontSize(
            context,
            mobile: mobileFontSize!,
            tablet: tabletFontSize,
            desktop: desktopFontSize,
          )
        : null;

    return Text(
      text,
      style: style?.copyWith(fontSize: adaptiveFontSize) ??
          TextStyle(fontSize: adaptiveFontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
