import 'package:flutter/material.dart';

@immutable
class ScreenPage {
  final Widget page;
  final String title;
  const ScreenPage({required this.page, required this.title});
}
