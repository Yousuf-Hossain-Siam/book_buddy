import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Config {
  final String baseUrl;
  const Config({required this.baseUrl});
}

final configProvider = Provider<Config>((ref) {
  throw StateError('Config provider was not overridden. Provide a flavor-specific Config in the entrypoint.');
});
