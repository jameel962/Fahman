import 'package:flutter/material.dart';

/// Global navigator key so non-widget code (e.g. interceptors) can navigate.
class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
