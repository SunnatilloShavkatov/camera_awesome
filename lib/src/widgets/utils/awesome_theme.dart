import "package:camera_awesome/src/widgets/utils/awesome_bouncing_widget.dart";
import "package:flutter/material.dart";

typedef ButtonBuilder = Widget Function(
  Widget child,
  VoidCallback onTap,
);

@immutable
class AwesomeTheme {
  AwesomeTheme({
    AwesomeButtonTheme? buttonTheme,
    Color? bottomActionsBackgroundColor,
  })  : buttonTheme = buttonTheme ?? AwesomeButtonTheme(),
        bottomActionsBackgroundColor =
            bottomActionsBackgroundColor ?? Colors.black54;
  final AwesomeButtonTheme buttonTheme;
  final Color bottomActionsBackgroundColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AwesomeTheme &&
          runtimeType == other.runtimeType &&
          buttonTheme == other.buttonTheme &&
          bottomActionsBackgroundColor == other.bottomActionsBackgroundColor;

  @override
  int get hashCode =>
      buttonTheme.hashCode ^ bottomActionsBackgroundColor.hashCode;

  AwesomeTheme copyWith({
    AwesomeButtonTheme? buttonTheme,
    Color? bottomActionsBackgroundColor,
  }) =>
      AwesomeTheme(
        buttonTheme: buttonTheme ?? this.buttonTheme,
        bottomActionsBackgroundColor:
            bottomActionsBackgroundColor ?? this.bottomActionsBackgroundColor,
      );
}

@immutable
class AwesomeButtonTheme {
  AwesomeButtonTheme({
    this.foregroundColor = Colors.white,
    this.backgroundColor = Colors.black12,
    this.iconSize = baseIconSize,
    this.padding = const EdgeInsets.all(12),
    this.shape = const CircleBorder(),
    this.rotateWithCamera = true,
    ButtonBuilder? buttonBuilder,
  }) : buttonBuilder = buttonBuilder ??
            ((Widget child, VoidCallback onTap) =>
                AwesomeBouncingWidget(onTap: onTap, child: child));
  final Color foregroundColor;
  final Color backgroundColor;
  final double iconSize;
  final EdgeInsets padding;
  final ShapeBorder shape;
  final bool rotateWithCamera;
  final ButtonBuilder buttonBuilder;

  static const double baseIconSize = 25;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AwesomeButtonTheme &&
          runtimeType == other.runtimeType &&
          foregroundColor == other.foregroundColor &&
          backgroundColor == other.backgroundColor &&
          iconSize == other.iconSize &&
          padding == other.padding &&
          shape == other.shape &&
          rotateWithCamera == other.rotateWithCamera &&
          buttonBuilder == other.buttonBuilder;

  @override
  int get hashCode =>
      foregroundColor.hashCode ^
      backgroundColor.hashCode ^
      iconSize.hashCode ^
      padding.hashCode ^
      shape.hashCode ^
      rotateWithCamera.hashCode ^
      buttonBuilder.hashCode;

  AwesomeButtonTheme copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
    double? iconSize,
    EdgeInsets? padding,
    ShapeBorder? shape,
    bool? rotateWithCamera,
    ButtonBuilder? buttonBuilder,
    double? baseIconSize,
  }) =>
      AwesomeButtonTheme(
        foregroundColor: foregroundColor ?? this.foregroundColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        iconSize: iconSize ?? this.iconSize,
        padding: padding ?? this.padding,
        shape: shape ?? this.shape,
        rotateWithCamera: rotateWithCamera ?? this.rotateWithCamera,
        buttonBuilder: buttonBuilder ?? this.buttonBuilder,
      );
}

class AwesomeThemeProvider extends InheritedWidget {
  AwesomeThemeProvider({
    super.key,
    AwesomeTheme? theme,
    required super.child,
  }) : theme = theme ?? AwesomeTheme();
  final AwesomeTheme theme;

  static AwesomeThemeProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AwesomeThemeProvider>()!;

  @override
  bool updateShouldNotify(covariant AwesomeThemeProvider oldWidget) =>
      theme != oldWidget.theme;
}
