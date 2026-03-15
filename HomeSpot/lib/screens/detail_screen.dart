import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/advert.dart';
import '../theme/app_theme.dart';

class DetailScreen extends StatefulWidget {
  final Advert advert;
  const DetailScreen({super.key, required this.advert});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _scrollCtrl = ScrollController();
  double _heroOpacity = 1;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollCtrl.offset;
    setState(() {
      _heroOpacity = (1 - offset / 200).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final advert = widget.advert;
    final screenHeight = MediaQuery.of(context).size.height;
    final isForSale = advert.adType == 'Sale';
    final isField = advert.estateType == 'Field';

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // ── Hero ──
              SliverToBoxAdapter(
                child: SizedBox(
                  height: screenHeight * 0.44,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: advert.imageUri,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.surfaceElevated,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceElevated,
                          child: Center(
                            child: Text(
                              advert.estateIcon,
                              style: const TextStyle(fontSize: 72),
                            ),
                          ),
                        ),
                      ),
                      // Cinematic scrim
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppGradients.heroScrim,
                        ),
                      ),

                      // Top nav
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: Opacity(
                            opacity: _heroOpacity,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _CircleButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: () => Navigator.pop(context),
                                ),
                                _TypePill(isForSale: isForSale),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Price + location at bottom of hero
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.lg,
                          ),
                          child: Opacity(
                            opacity: _heroOpacity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      advert.formattedPrice,
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryLight,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'TND',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        if (!isForSale)
                                          const Text(
                                            '/month',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ──
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -AppRadius.xl),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xl),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gold handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 3,
                            margin: const EdgeInsets.only(top: 14, bottom: AppSpacing.lg),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.primary,
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                  
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          advert.estateType,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                            letterSpacing: -0.8,
                                            height: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 13,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              advert.location,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                  
                              // Stats grid
                              _StatsGrid(advert: advert, isField: isField),
                              const SizedBox(height: AppSpacing.xl),
                  
                              // Gold divider
                              Container(
                                height: 1,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.primary,
                                      AppColors.secondary,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                  
                              // Description
                              const _SectionLabel(label: 'About This Property'),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                advert.description,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  height: 1.7,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                  
                              // Details
                              const _SectionLabel(label: 'Property Details'),
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: AppColors.cardBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    _DetailRow(
                                      label: 'Type',
                                      value: advert.estateType,
                                      icon: Icons.home_outlined,
                                      isFirst: true,
                                    ),
                                    _DetailRow(
                                      label: 'Listing',
                                      value: advert.adType,
                                      icon: isForSale
                                          ? Icons.sell_outlined
                                          : Icons.key_outlined,
                                    ),
                                    _DetailRow(
                                      label: 'Location',
                                      value: advert.location,
                                      icon: Icons.location_city_outlined,
                                    ),
                                    _DetailRow(
                                      label: 'Surface Area',
                                      value:
                                          '${advert.surfaceArea.toStringAsFixed(0)} m²',
                                      icon: Icons.straighten_outlined,
                                    ),
                                    if (!isField && advert.nbRooms != null)
                                      _DetailRow(
                                        label: 'Rooms',
                                        value: '${advert.nbRooms}',
                                        icon: Icons.bed_outlined,
                                      ),
                                    _DetailRow(
                                      label: 'Listed',
                                      value: _formatDate(advert.createdAt),
                                      icon: Icons.calendar_today_outlined,
                                      isLast: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky CTA ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg +
                    MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: AppColors.cardBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Price chip
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL PRICE',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${advert.formattedPrice} TND',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // CTA button
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryLight,
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: AppShadows.goldGlow,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: AppColors.background,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'CONTACT AGENT',
                              style: TextStyle(
                                color: AppColors.background,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final bool isForSale;
  const _TypePill({required this.isForSale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isForSale
              ? AppColors.primary.withValues(alpha: 0.6)
              : AppColors.secondary.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isForSale ? AppColors.primary : AppColors.secondary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isForSale ? 'FOR SALE' : 'FOR RENT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color:
                  isForSale ? AppColors.primaryLight : AppColors.secondary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Advert advert;
  final bool isField;
  const _StatsGrid({required this.advert, required this.isField});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.straighten_outlined,
            label: 'Surface',
            value: advert.surfaceArea.toStringAsFixed(0),
            unit: 'm²',
          ),
        ),
        if (!isField && advert.nbRooms != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatTile(
              icon: Icons.bed_outlined,
              label: 'Rooms',
              value: '${advert.nbRooms}',
              unit: 'rooms',
            ),
          ),
        ],
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: advert.adType == 'Sale'
                ? Icons.sell_outlined
                : Icons.key_outlined,
            label: 'Listing',
            value: advert.adType,
            highlight: true,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final bool highlight;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.cardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: highlight ? AppColors.primary : AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.primaryLight : AppColors.text,
                letterSpacing: -0.3,
              ),
              children: unit != null
                  ? [
                      TextSpan(
                        text: ' $unit',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                          letterSpacing: 0,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.primary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isFirst;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.cardBorder, width: 1),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}