import 'package:flutter/material.dart';

import 'app.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.instance.init();
  runApp(const App());
}
