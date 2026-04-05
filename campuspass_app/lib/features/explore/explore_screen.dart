import 'package:flutter/material.dart';

import 'explore_screen_tabs.dart';

/// Wrapper pour compatibilité.
/// L'écran réel est `ExploreTabsScreen` (onglets Offres/Commerces).
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExploreTabsScreen();
  }
}
