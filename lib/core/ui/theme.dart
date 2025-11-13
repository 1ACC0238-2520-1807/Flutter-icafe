import "package:flutter/material.dart";

class IcafeTheme {
  final TextTheme textTheme;

  const IcafeTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff8b4f25),
      surfaceTint: Color(0xff8b4f25),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffffdbc7),
      onPrimaryContainer: Color(0xff6e380f),
      secondary: Color(0xff755846),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffdbc7),
      onSecondaryContainer: Color(0xff5b4130),
      tertiary: Color(0xff616134),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe7e6ad),
      onTertiaryContainer: Color(0xff49491e),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff221a15),
      onSurfaceVariant: Color(0xff52443c),
      outline: Color(0xff84746a),
      outlineVariant: Color(0xffd7c3b8),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e29),
      inversePrimary: Color(0xffffb688),
      primaryFixed: Color(0xffffdbc7),
      onPrimaryFixed: Color(0xff311300),
      primaryFixedDim: Color(0xffffb688),
      onPrimaryFixedVariant: Color(0xff6e380f),
      secondaryFixed: Color(0xffffdbc7),
      onSecondaryFixed: Color(0xff2b1709),
      secondaryFixedDim: Color(0xffe5bfa9),
      onSecondaryFixedVariant: Color(0xff5b4130),
      tertiaryFixed: Color(0xffe7e6ad),
      onTertiaryFixed: Color(0xff1d1d00),
      tertiaryFixedDim: Color(0xffcac993),
      onTertiaryFixedVariant: Color(0xff49491e),
      surfaceDim: Color(0xffe7d7ce),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ea),
      surfaceContainer: Color(0xfffcebe2),
      surfaceContainerHigh: Color(0xfff6e5dc),
      surfaceContainerHighest: Color(0xfff0dfd7),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff5a2801),
      surfaceTint: Color(0xff8b4f25),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff9d5d32),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff493121),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff856754),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff38380f),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff706f41),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff17100b),
      onSurfaceVariant: Color(0xff40332c),
      outline: Color(0xff5e4f47),
      outlineVariant: Color(0xff7a6a61),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e29),
      inversePrimary: Color(0xffffb688),
      primaryFixed: Color(0xff9d5d32),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff7f461c),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff856754),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff6b4f3d),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff706f41),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff57572b),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd3c3bb),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ea),
      surfaceContainer: Color(0xfff6e5dc),
      surfaceContainerHigh: Color(0xffeadad1),
      surfaceContainerHighest: Color(0xffdfcec6),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff4b2000),
      surfaceTint: Color(0xff8b4f25),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff713b11),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff3e2718),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5e4332),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2e2e06),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4b4b20),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff362a22),
      outlineVariant: Color(0xff54463e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff382e29),
      inversePrimary: Color(0xffffb688),
      primaryFixed: Color(0xff713b11),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff552500),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5e4332),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff452d1e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4b4b20),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff34340c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc5b6ae),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffede5),
      surfaceContainer: Color(0xfff0dfd7),
      surfaceContainerHigh: Color(0xffe2d1c9),
      surfaceContainerHighest: Color(0xffd3c3bb),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb688),
      surfaceTint: Color(0xffffb688),
      onPrimary: Color(0xff512400),
      primaryContainer: Color(0xff6e380f),
      onPrimaryContainer: Color(0xffffdbc7),
      secondary: Color(0xffe5bfa9),
      onSecondary: Color(0xff432b1c),
      secondaryContainer: Color(0xff5b4130),
      onSecondaryContainer: Color(0xffffdbc7),
      tertiary: Color(0xffcac993),
      onTertiary: Color(0xff323209),
      tertiaryContainer: Color(0xff49491e),
      onTertiaryContainer: Color(0xffe7e6ad),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff19120d),
      onSurface: Color(0xfff0dfd7),
      onSurfaceVariant: Color(0xffd7c3b8),
      outline: Color(0xff9f8d83),
      outlineVariant: Color(0xff52443c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd7),
      inversePrimary: Color(0xff8b4f25),
      primaryFixed: Color(0xffffdbc7),
      onPrimaryFixed: Color(0xff311300),
      primaryFixedDim: Color(0xffffb688),
      onPrimaryFixedVariant: Color(0xff6e380f),
      secondaryFixed: Color(0xffffdbc7),
      onSecondaryFixed: Color(0xff2b1709),
      secondaryFixedDim: Color(0xffe5bfa9),
      onSecondaryFixedVariant: Color(0xff5b4130),
      tertiaryFixed: Color(0xffe7e6ad),
      onTertiaryFixed: Color(0xff1d1d00),
      tertiaryFixedDim: Color(0xffcac993),
      onTertiaryFixedVariant: Color(0xff49491e),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff413731),
      surfaceContainerLowest: Color(0xff140d08),
      surfaceContainerLow: Color(0xff221a15),
      surfaceContainer: Color(0xff261e19),
      surfaceContainerHigh: Color(0xff312823),
      surfaceContainerHighest: Color(0xff3d332d),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd4ba),
      surfaceTint: Color(0xffffb688),
      onPrimary: Color(0xff411b00),
      primaryContainer: Color(0xffc68051),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffcd4be),
      onSecondary: Color(0xff362012),
      secondaryContainer: Color(0xffac8a76),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffe0dfa7),
      onTertiary: Color(0xff272702),
      tertiaryContainer: Color(0xff949361),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff19120d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffedd8cd),
      outline: Color(0xffc1aea4),
      outlineVariant: Color(0xff9f8d83),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd7),
      inversePrimary: Color(0xff703a10),
      primaryFixed: Color(0xffffdbc7),
      onPrimaryFixed: Color(0xff210b00),
      primaryFixedDim: Color(0xffffb688),
      onPrimaryFixedVariant: Color(0xff5a2801),
      secondaryFixed: Color(0xffffdbc7),
      onSecondaryFixed: Color(0xff1f0c02),
      secondaryFixedDim: Color(0xffe5bfa9),
      onSecondaryFixedVariant: Color(0xff493121),
      tertiaryFixed: Color(0xffe7e6ad),
      onTertiaryFixed: Color(0xff121200),
      tertiaryFixedDim: Color(0xffcac993),
      onTertiaryFixedVariant: Color(0xff38380f),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff4d423c),
      surfaceContainerLowest: Color(0xff0c0603),
      surfaceContainerLow: Color(0xff241c17),
      surfaceContainer: Color(0xff2f2621),
      surfaceContainerHigh: Color(0xff3a312b),
      surfaceContainerHighest: Color(0xff463c36),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece3),
      surfaceTint: Color(0xffffb688),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffb17f),
      onPrimaryContainer: Color(0xff180600),
      secondary: Color(0xffffece3),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffe1bba5),
      onSecondaryContainer: Color(0xff180701),
      tertiary: Color(0xfff4f3b9),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffc6c68f),
      onTertiaryContainer: Color(0xff0c0c00),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff19120d),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece3),
      outlineVariant: Color(0xffd3bfb4),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfd7),
      inversePrimary: Color(0xff703a10),
      primaryFixed: Color(0xffffdbc7),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb688),
      onPrimaryFixedVariant: Color(0xff210b00),
      secondaryFixed: Color(0xffffdbc7),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffe5bfa9),
      onSecondaryFixedVariant: Color(0xff1f0c02),
      tertiaryFixed: Color(0xffe7e6ad),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffcac993),
      onTertiaryFixedVariant: Color(0xff121200),
      surfaceDim: Color(0xff19120d),
      surfaceBright: Color(0xff594e48),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff261e19),
      surfaceContainer: Color(0xff382e29),
      surfaceContainerHigh: Color(0xff443934),
      surfaceContainerHighest: Color(0xff4f453f),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
