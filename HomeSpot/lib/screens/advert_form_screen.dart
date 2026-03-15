import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/advert.dart';
import '../providers/adverts_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/styled_input.dart';
import '../widgets/styled_picker.dart';
import '../theme/app_theme.dart';

const _adTypeOptions = [
  PickerOption(label: 'For Sale', value: 'Sale'),
  PickerOption(label: 'For Rent', value: 'Rent'),
];

const _estateTypeOptions = [
  PickerOption(label: 'Apartment', value: 'Apartment'),
  PickerOption(label: 'House', value: 'House'),
  PickerOption(label: 'Office', value: 'Office'),
  PickerOption(label: 'Field', value: 'Field'),
];

const _locationOptions = [
  'Tunis', 'Sfax', 'Sousse', 'Monastir', 'Nabeul',
  'Hammamet', 'Bizerte', 'Ariana', 'Ben Arous', 'Manouba',
];

class AdvertFormScreen extends StatefulWidget {
  final Advert? existing;
  const AdvertFormScreen({super.key, this.existing});

  @override
  State<AdvertFormScreen> createState() => _AdvertFormScreenState();
}

class _AdvertFormScreenState extends State<AdvertFormScreen> {
  late String _adType;
  late String _estateType;
  late String _location;
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _surfaceCtrl = TextEditingController();
  final _roomsCtrl = TextEditingController();

  String? _imageLocalPath;
  String? _imageNetworkUrl;
  bool _loading = false;

  Map<String, String?> _errors = {};

  bool get isEdit => widget.existing != null;
  bool get isField => _estateType == 'Field';

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _adType = e?.adType ?? 'Sale';
    _estateType = e?.estateType ?? 'Apartment';
    _location = e?.location ?? 'Tunis';
    _descCtrl.text = e?.description ?? '';
    _priceCtrl.text = e?.price.toString() ?? '';
    _surfaceCtrl.text = e?.surfaceArea.toString() ?? '';
    _roomsCtrl.text = e?.nbRooms?.toString() ?? '';
    _imageNetworkUrl = e?.imageURL;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _surfaceCtrl.dispose();
    _roomsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _imageLocalPath = picked.path);
    }
  }

  bool _validate() {
    final errors = <String, String?>{};
    if (_descCtrl.text.trim().isEmpty) errors['description'] = 'Required';
    if (_priceCtrl.text.isEmpty ||
        double.tryParse(_priceCtrl.text) == null) {
      errors['price'] = 'Enter a valid number';
    }
    if (_surfaceCtrl.text.isEmpty ||
        double.tryParse(_surfaceCtrl.text) == null) {
      errors['surfaceArea'] = 'Enter a valid number';
    }
    if (!isField &&
        (_roomsCtrl.text.isEmpty ||
            int.tryParse(_roomsCtrl.text) == null)) {
      errors['nbRooms'] = 'Required for this estate type';
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Map<String, String> _buildFields() {
    final fields = {
      'adType': _adType,
      'estateType': _estateType,
      'location': _location,
      'description': _descCtrl.text,
      'price': _priceCtrl.text,
      'surfaceArea': _surfaceCtrl.text,
    };
    if (!isField && _roomsCtrl.text.isNotEmpty) {
      fields['nbRooms'] = _roomsCtrl.text;
    }
    return fields;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      final provider = context.read<AdvertsProvider>();
      final fields = _buildFields();
      final imageFile =
          _imageLocalPath != null ? File(_imageLocalPath!) : null;

      if (isEdit) {
        await provider.update(widget.existing!.id,
            fields: fields, imageFile: imageFile);
      } else {
        await provider.create(fields: fields, imageFile: imageFile);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isEdit ? 'Edit Listing' : 'New Listing',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 38),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 1,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primary,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    // Image picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: _imageLocalPath != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(_imageLocalPath!),
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    child: const Center(
                                      child: _ImageChangeHint(),
                                    ),
                                  ),
                                ],
                              )
                            : _imageNetworkUrl != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        _imageNetworkUrl!.startsWith('http')
                                            ? _imageNetworkUrl!
                                            : 'http://192.168.1.6:3000$_imageNetworkUrl',
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        color:
                                            Colors.black.withValues(alpha: 0.5),
                                        child: const Center(
                                          child: _ImageChangeHint(),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Add Property Photo',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Recommended: 16:9 ratio',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Pickers row
                    Row(
                      children: [
                        Expanded(
                          child: StyledPicker(
                            label: 'Listing Type',
                            options: _adTypeOptions,
                            value: _adType,
                            onChange: (v) =>
                                setState(() => _adType = v),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: StyledPicker(
                            label: 'Estate Type',
                            options: _estateTypeOptions,
                            value: _estateType,
                            onChange: (v) =>
                                setState(() => _estateType = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    StyledPicker(
                      label: 'Location',
                      options: _locationOptions
                          .map((l) =>
                              PickerOption(label: l, value: l))
                          .toList(),
                      value: _location,
                      onChange: (v) =>
                          setState(() => _location = v),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: StyledInput(
                            label: 'Price (TND)',
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            placeholder: '250,000',
                            error: _errors['price'],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: StyledInput(
                            label: 'Surface (m²)',
                            controller: _surfaceCtrl,
                            keyboardType: TextInputType.number,
                            placeholder: '120',
                            error: _errors['surfaceArea'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (!isField) ...[
                      StyledInput(
                        label: 'Number of Rooms',
                        controller: _roomsCtrl,
                        keyboardType: TextInputType.number,
                        placeholder: '3',
                        error: _errors['nbRooms'],
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    StyledInput(
                      label: 'Description',
                      controller: _descCtrl,
                      placeholder: 'Describe the property...',
                      maxLines: 5,
                      minLines: 4,
                      error: _errors['description'],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    GradientButton(
                      label: isEdit ? 'Save Changes' : 'Publish Listing',
                      onPress: _handleSubmit,
                      loading: _loading,
                      size: ButtonSize.lg,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageChangeHint extends StatelessWidget {
  const _ImageChangeHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.edit_outlined,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Change Photo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}