import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedbackFixed {

  FeedbackFixed._();

  /// Wraps a [Function] to provide platform specific feedback for a
  /// click before the provided callback is executed.
  static VoidCallback? wrapTouch<T>(Function()? callback, BuildContext context) {
    if (callback == null)
      return null;
    return () {
      FeedbackFixed.touch(context);
      callback();
    };
  }
  /// Wraps a [Function] to provide platform specific feedback for a
  /// long click before the provided callback is executed.
  static VoidCallback? wrapLongTouch<T>(Function? callback, BuildContext context) {
    if (callback == null)
      return null;
    return () {
      FeedbackFixed.longTouch(context);
      callback();
    };
  }
  static Future<void> longTouch(BuildContext context) async {
    switch (_platform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return HapticFeedback.vibrate();
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return Future<void>.value();
    }
  }
  static Future<void> touch(BuildContext context) async {
    switch (_platform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return HapticFeedback.mediumImpact();
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return Future<void>.value();
    }
  }

  static TargetPlatform _platform(BuildContext context) => Theme.of(context).platform;
}
