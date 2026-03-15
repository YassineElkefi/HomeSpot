import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/adverts_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/advert_card.dart';
import '../widgets/filter_bar.dart';
import '../theme/app_theme.dart';

const _adTypeFilters = [
  FilterOption(label: 'All', value: 'all'),
  FilterOption(label: 'For Sale', value: 'Sale'),
  FilterOption(label: 'For Rent', value: 'Rent'),
];

const _estateFilters = [
  FilterOption(label: 'All Types', value: 'all'),
  FilterOption(label: 'Apartment', value: 'Apartment'),
  FilterOption(label: 'House', value: 'House'),
  FilterOption(label: 'Office', value: 'Office'),
  FilterOption(label: 'Field', value: 'Field'),
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Timer? _searchTimer;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _headerCompact = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdvertsProvider>().fetch();
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final compact = _scrollCtrl.offset > 60;
    if (compact != _headerCompact) {
      setState(() => _headerCompact = compact);
    }
    // Infinite scroll
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<AdvertsProvider>().fetchMore();
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _handleSearch(String text) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 350), () {
      final provider = context.read<AdvertsProvider>();
      final current = provider.filters;
      provider.setFilters(
        text.isEmpty
            ? current.copyWith(clearQ: true)
            : current.copyWith(q: text),
      );
    });
  }

  void _handleAdTypeFilter(String value) {
    final provider = context.read<AdvertsProvider>();
    final current = provider.filters;
    provider.setFilters(
      value == 'all'
          ? current.copyWith(clearAdType: true)
          : current.copyWith(adType: value),
    );
  }

  void _handleEstateFilter(String value) {
    final provider = context.read<AdvertsProvider>();
    final current = provider.filters;
    provider.setFilters(
      value == 'all'
          ? current.copyWith(clearEstateType: true)
          : current.copyWith(estateType: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final advertsProvider = context.watch<AdvertsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final filters = advertsProvider.filters;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                _headerCompact ? AppSpacing.sm : AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: _headerCompact ? 16 : 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                                letterSpacing: _headerCompact ? 0 : -0.5,
                              ),
                              child: Text(
                                user != null
                                    ? 'Hello, ${user.displayLabel}'
                                    : 'Discover Properties',
                              ),
                            ),
                            if (!_headerCompact) ...[
                              const SizedBox(height: 3),
                              Text(
                                '${advertsProvider.adverts.length} properties available',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (user?.isAdmin == true)
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/crud'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      size: 12,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'ADMIN',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () =>
                                authProvider.signOut(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: AppColors.cardBorder,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Search ──
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.md),
                          child: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: _handleSearch,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.text,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search city, type, keyword...',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Filters ──
            FilterBar(
              filters: _adTypeFilters,
              activeValue: filters.adType ?? 'all',
              onSelect: _handleAdTypeFilter,
            ),
            const SizedBox(height: 6),
            FilterBar(
              filters: _estateFilters,
              activeValue: filters.estateType ?? 'all',
              onSelect: _handleEstateFilter,
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── List ──
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () => advertsProvider.fetch(),
                child: advertsProvider.adverts.isEmpty &&
                        !advertsProvider.loading
                    ? ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.full),
                                    border: Border.all(
                                      color: AppColors.cardBorder,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.home_work_outlined,
                                      size: 32,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Text(
                                  'No properties found',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Adjust your search filters',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.only(
                          top: AppSpacing.sm,
                          bottom: 100,
                        ),
                        itemCount: advertsProvider.adverts.length +
                            (advertsProvider.loading ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == advertsProvider.adverts.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppSpacing.lg),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 1.5,
                                  ),
                                ),
                              ),
                            );
                          }
                          final advert = advertsProvider.adverts[i];
                          return AdvertCard(
                            advert: advert,
                            onPress: () => Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: advert,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}