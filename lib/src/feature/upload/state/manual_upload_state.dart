import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/extension/number_extension.dart';
import '../../../common/router/pages.dart';
import '../bloc/upload_pricing_cubit.dart';
import '../screen/manual_upload_screen.dart';

abstract class ManualUploadState extends State<ManualUploadScreen> {
  final universityController = TextEditingController();
  final testNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final universityFocus = FocusNode();
  final testNameFocus = FocusNode();
  final descriptionFocus = FocusNode();
  final priceFocus = FocusNode();

  bool showAuthorship = true;
  bool exitFullScreen = true;

  /// Validation error for the sale-price field ("kamida N so'm"), or null.
  String? priceError;

  late final UploadPricingCubit pricingCubit;

  // ── Submit guard ──────────────────────────────────────────────────────

  bool get canProceed => universityController.text.trim().isNotEmpty && testNameController.text.trim().isNotEmpty;

  /// Hard floor for the sale price, from pricing settings ("Minimal narx").
  int get minTestPrice => pricingCubit.state.pricing.minTestPrice;

  // ── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    context.setupTelegramBackButton();
    pricingCubit = UploadPricingCubit(uploadRepository: context.x.dependencies.repository.uploadRepository)
      ..fetchPricing();
    universityController.addListener(_onFieldChanged);
    testNameController.addListener(_onFieldChanged);
    priceController.addListener(_onPriceChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.isTelegramSupported && exitFullScreen) {
        context.exitFullscreen();
      }
    });
  }

  void _onFieldChanged() => setState(() {});

  void _onPriceChanged() {
    if (priceError != null) setState(() => priceError = null);
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton();
    universityController
      ..removeListener(_onFieldChanged)
      ..dispose();
    testNameController
      ..removeListener(_onFieldChanged)
      ..dispose();
    descriptionController.dispose();
    priceController
      ..removeListener(_onPriceChanged)
      ..dispose();

    universityFocus.dispose();
    testNameFocus.dispose();
    descriptionFocus.dispose();
    priceFocus.dispose();
    pricingCubit.close();
    super.dispose();
  }

  // ── Toggle handlers ───────────────────────────────────────────────────

  void onToggleAuthorship(bool value) {
    context.telegramWebApp.hapticImpact(.soft);
    setState(() => showAuthorship = value);
  }

  void onToggleExitFullScreen(bool value) {
    setState(() => exitFullScreen = value);
    if (value) {
      context.exitFullscreen();
    } else {
      context.requestFullscreen();
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────

  void onSubmitProceed() {
    if (!canProceed) return;
    context.telegramWebApp.hapticImpact(.medium);

    final university = universityController.text.trim();
    final testName = testNameController.text.trim();
    final description = descriptionController.text.trim();

    if (university.isEmpty) {
      universityFocus.requestFocus();
      return;
    }

    if (testName.isEmpty) {
      testNameFocus.requestFocus();
      return;
    }

    final rawPrice = priceController.text.replaceAll(RegExp(r'\D'), '');
    final price = int.tryParse(rawPrice);

    // A typed price must clear the floor; leaving it blank is fine — the
    // suggested price is applied once the question count is known.
    if (price != null && price > 0 && price < minTestPrice) {
      setState(() => priceError = context.x.l10n.priceBelowMinError(minTestPrice.formatUzs));
      priceFocus.requestFocus();
      return;
    }

    context.octopus.push(
      Routes.createTestQuestions,
      arguments: {
        'testName': testName,
        'university': university,
        if (description.isNotEmpty) 'description': description,
        if (price != null && price > 0) 'price': price.toString(),
      },
    );
  }
}
