import 'package:cheon/app.dart';
import 'package:cheon/dependency_injection.dart';
import 'package:cheon/flavor_config.dart';
import 'package:flutter/material.dart';

/// Runs the app with the staging backend mode
Future<void> main() async {
  configureApp();

  FlavorConfig(color: Colors.orange, flavor: Flavor.STAGING);

  await registerDependencies();

  runApp(const App());
}
