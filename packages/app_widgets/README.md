# Package Name

The `app_widgets` package provides a collection of customizable and reusable UI components for Flutter applications. It aims to simplify the development process by offering pre-built widgets that can be easily integrated into your projects.

## Features

- A variety of customizable widgets designed for common use cases in Flutter apps.
- Simplified integration with other libraries using modular architecture.
- Support for vector graphics with `flutter_svg` for scalable image rendering.
- Animation utilities through `flutter_animate` to enhance user experience.

## Installation

To use the `app_widgets` package, add it as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  app_widgets:
    path: packages/app_widgets
```

## Dependencies

The package relies on the following dependencies to deliver its features:

- `flutter_animate: 4.5.2`: Allows for easy and expressive animations within the app.
- `flutter_modular`: Supports modular architecture for better organization and scalability.
- `flutter_rearch`: Provides architectural patterns for app development.
- `flutter_svg: 2.0.16`: Supports rendering of SVG images for high-quality graphics.
- `gap: 3.0.1`: Helps in creating spacing and layout structures.
- `rearch`: Offers architectural tools and patterns to improve app functionality.

## Dev Dependencies

- `flutter_test`: Flutter testing library for building unit and integration tests.
- `very_good_analysis: ^7.0.0`: A set of lint rules and best practices to ensure consistent and high-quality code.