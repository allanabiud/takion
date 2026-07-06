import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// This class defines light theme and dark theme
class AppThemes {
  static ThemeData light() {
    final ThemeData base = FlexThemeData.light(
      scheme: FlexScheme.bigStone,
      fontFamily: 'Rubik',
      appBarOpacity: 0.0,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        useM2StyleDividerInM3: true,
        tabBarDividerColor: Color(0x00000000),
        tabBarIndicatorWeight: 4,
        tabBarIndicatorTopRadius: 0,
        progressIndicatorYear2023: false,
        filledButtonRadius: 10.0,
        filledButtonTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        elevatedButtonRadius: 10.0,
        outlinedButtonRadius: 10.0,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorIsFilled: true,
        inputDecoratorContentPadding: EdgeInsetsDirectional.fromSTEB(
          12,
          20,
          12,
          20,
        ),
        inputDecoratorBackgroundAlpha: 30,
        inputDecoratorBorderSchemeColor: SchemeColor.primary,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 10.0,
        inputDecoratorUnfocusedBorderIsColored: true,
        inputDecoratorBorderWidth: 1.0,
        inputDecoratorFocusedBorderWidth: 2.0,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        inputDecoratorSuffixIconSchemeColor: SchemeColor.primary,
        listTileIconSchemeColor: SchemeColor.primary,
        alignedDropdown: true,
        appBarCenterTitle: true,
        navigationBarLabelTextStyle: TextStyle(fontSize: 14),
        navigationBarUnselectedIconSize: 26,
        navigationBarSelectedIconSize: 26,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        useError: true,
      ),
      variant: FlexSchemeVariant.expressive,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    );

    final scheme = base.colorScheme;

    return base.copyWith(
      colorScheme: scheme,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        iconTheme: const IconThemeData(size: 28),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Rubik',
          color: scheme.onSurface,
        ),
        actionsIconTheme: const IconThemeData(size: 30),
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        extendedSizeConstraints: const BoxConstraints.tightFor(height: 70),
        extendedTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Rubik',
        ),
        iconSize: 30,
      ),
    );
  }

  static ThemeData dark({
    bool darkIsTrueBlack = false,
  }) {
    final ThemeData base = FlexThemeData.dark(
      scheme: FlexScheme.bigStone,
      fontFamily: 'Rubik',
      appBarOpacity: 0.0,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 8,
      darkIsTrueBlack: darkIsTrueBlack,
      subThemesData: const FlexSubThemesData(
        interactionEffects: true,
        tintedDisabledControls: true,
        blendOnColors: true,
        useM2StyleDividerInM3: true,
        adaptiveAppBarScrollUnderOff: FlexAdaptive.all(),
        tabBarDividerColor: Color(0x00000000),
        tabBarIndicatorWeight: 4,
        tabBarIndicatorTopRadius: 0,
        progressIndicatorYear2023: false,
        filledButtonRadius: 10.0,
        filledButtonTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Rubik',
          ),
        ),
        elevatedButtonRadius: 10.0,
        outlinedButtonRadius: 10.0,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorIsFilled: true,
        inputDecoratorContentPadding: EdgeInsetsDirectional.fromSTEB(
          12,
          20,
          12,
          20,
        ),
        inputDecoratorBackgroundAlpha: 30,
        inputDecoratorBorderSchemeColor: SchemeColor.primary,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 10.0,
        inputDecoratorUnfocusedBorderIsColored: true,
        inputDecoratorBorderWidth: 1.0,
        inputDecoratorFocusedBorderWidth: 2.0,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        inputDecoratorSuffixIconSchemeColor: SchemeColor.primary,
        listTileIconSchemeColor: SchemeColor.primary,
        alignedDropdown: true,
        appBarCenterTitle: true,
        navigationBarLabelTextStyle: TextStyle(fontSize: 14),
        navigationBarUnselectedIconSize: 26,
        navigationBarSelectedIconSize: 26,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
        useError: true,
      ),
      variant: FlexSchemeVariant.expressive,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
    );

    final scheme = base.colorScheme;

    return base.copyWith(
      colorScheme: scheme,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        iconTheme: const IconThemeData(size: 28),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Rubik',
          color: scheme.onSurface,
        ),
        actionsIconTheme: const IconThemeData(size: 30),
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        extendedSizeConstraints: const BoxConstraints.tightFor(height: 70),
        extendedTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Rubik',
        ),
        iconSize: 30,
      ),
    );
  }
}
