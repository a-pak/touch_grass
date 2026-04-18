import 'package:flutter/material.dart';

/// Shared tab index so any screen can switch HomeScreen tabs without prop-drilling.
final ValueNotifier<int> homeTabIndexNotifier = ValueNotifier<int>(0);
