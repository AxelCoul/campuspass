import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared_widgets/layout/app_header.dart';
import '../../shared_widgets/navigation/main_tab_bar.dart';
import '../../services/merchants_service.dart';
import '../../services/student_service.dart';
import '../../services/auth_service.dart';
import '../explore/explore_screen_tabs.dart';
import '../economy/economy_screen.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/screens/notifications_screen.dart';
import 'widgets/home_content.dart';

class _AreaOption {
  const _AreaOption({required this.city, required this.country});

  final String city;
  final String? country;

  String get key => '${city.toLowerCase()}|${country?.toLowerCase() ?? ''}';

  String get label => country == null || country!.trim().isEmpty
      ? city
      : '$city, $country';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialIndex = 0,
    this.initialCity,
    this.initialCountry,
    this.initialCategoryId,
    this.initialMerchantId,
  });

  /// Index initial des onglets (0..4).
  final int initialIndex;
  final String? initialCity;
  final String? initialCountry;
  final int? initialCategoryId;
  final int? initialMerchantId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  late final PageController _pageController;

  String? _selectedCity;
  String? _selectedCountry;
  List<_AreaOption> _areas = const [];
  bool _areasLoading = true;

  int? _initialCategoryId;
  int? _initialMerchantId;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
    _pageController = PageController(initialPage: _currentIndex);
    _selectedCity = widget.initialCity;
    _selectedCountry = widget.initialCountry;
    _initialCategoryId = widget.initialCategoryId;
    _initialMerchantId = widget.initialMerchantId;
    _initAreas();
  }

  Future<void> _initAreas() async {
    try {
      final merchants = await MerchantsService.instance.getAll();

      final map = <String, _AreaOption>{};
      for (final m in merchants) {
        final city = m.city?.trim();
        if (city == null || city.isEmpty) continue;
        final country = m.country?.trim();
        final opt = _AreaOption(city: city, country: country);
        map[opt.key] = opt;
      }

      final areas = map.values.toList()
        ..sort((a, b) => a.city.toLowerCase().compareTo(b.city.toLowerCase()));

      // Priorité : initialCity -> city du profil (si connecté) -> première zone connue.
      String? cityFromProfile;
      String? countryFromProfile;
      if (AuthService.instance.isLoggedIn) {
        try {
          final me = await StudentService.instance.getMe();
          cityFromProfile = me.city?.trim();
          countryFromProfile = me.country?.trim();
        } catch (_) {
          cityFromProfile = null;
          countryFromProfile = null;
        }
      }

      final cityToUse = _selectedCity ?? cityFromProfile;

      String? countryToUse = _selectedCountry ?? countryFromProfile;
      if (cityToUse != null && countryToUse == null) {
        final match = areas.firstWhere(
          (a) => a.city.toLowerCase() == cityToUse.toLowerCase(),
          orElse: () => const _AreaOption(city: 'Ouagadougou', country: null),
        );
        // Si on n'a rien trouvé, on garde la country null.
        if (match.city.toLowerCase() != cityToUse.toLowerCase()) {
          countryToUse = null;
        } else {
          countryToUse = match.country;
        }
      }

      if (cityToUse == null && areas.isNotEmpty) {
        _selectedCity = areas.first.city;
        _selectedCountry = areas.first.country;
      } else {
        _selectedCity = cityToUse;
        _selectedCountry = countryToUse;
      }

      setState(() {
        _areas = areas;
        _areasLoading = false;
      });
    } catch (_) {
      setState(() {
        _areasLoading = false;
      });
    }
  }

  String get _headerCityName {
    final city = _selectedCity?.trim();
    if (city == null || city.isEmpty) return 'Toutes les zones';
    final country = _selectedCountry?.trim();
    if (country == null || country.isEmpty) return city;
    return '$city, $country';
  }

  Future<void> _persistAreaSelection({
    required String? city,
    required String? country,
  }) async {
    try {
      await StudentService.instance.updateArea(city: city, country: country);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La zone n'a pas pu etre sauvegardee pour le moment.",
          ),
        ),
      );
    }
  }

  void _openCityPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Changer de zone',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                ListTile(
                  title: const Text('Toutes les zones'),
                  leading: Icon(
                    Icons.public_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: _selectedCity == null
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCity = null;
                      _selectedCountry = null;
                    });
                    _persistAreaSelection(city: null, country: null);
                    Navigator.of(ctx).pop();
                  },
                ),
                const Divider(height: 1),
                Expanded(
                  child: _areasLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _areas.length,
                          itemBuilder: (context, index) {
                            final opt = _areas[index];
                            final selected = opt.city.toLowerCase() ==
                                    (_selectedCity ?? '').toLowerCase() &&
                                (opt.country?.toLowerCase() ??
                                        '') ==
                                    (_selectedCountry ?? '').toLowerCase();
                            return ListTile(
                              title: Text(opt.label),
                              trailing: selected
                                  ? const Icon(Icons.check_rounded)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedCity = opt.city;
                                  _selectedCountry = opt.country;
                                });
                                _persistAreaSelection(
                                  city: opt.city,
                                  country: opt.country,
                                );
                                Navigator.of(ctx).pop();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarTop = MediaQuery.paddingOf(context).top;
    return Theme(
      data: buildAppTheme(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _currentIndex == 0
            ? PreferredSize(
                preferredSize: Size.fromHeight(72 + statusBarTop),
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Transform.translate(
                    offset: const Offset(0, 6),
                    child: AppHeader(
                      cityName: _headerCityName,
                      onChangeCity: _openCityPicker,
                      onNotificationsTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              HomeContent(
                city: _selectedCity,
                country: _selectedCountry,
              ),
              ExploreTabsScreen(
                city: _selectedCity,
                country: _selectedCountry,
                initialCategoryId: _initialCategoryId,
                initialMerchantId: _initialMerchantId,
              ),
              const EconomyScreen(),
              const FavoritesScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: MainTabBar(
          currentIndex: _currentIndex,
          onTabSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
            );
          },
        ),
      ),
    );
  }

}
