import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

import '../../../common/extension/context_extension.dart';
import '../../../common/router/pages.dart';
import '../widget/header_widget.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  AppLanguage _selected = .uzLatin;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.white,
    body: SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const .all(16),
        children: [
          HeaderWidget(title: context.x.l10n.quizlyMarket, subtitle: 'Testlarga tayyorlovchi aqlli platforma'),
          const SizedBox(height: 24),
          Column(
            spacing: 8,
            children: [
              LanguageTile(
                title: "O'zbek",
                subtitle: 'Lotin alifbosida',
                isSelected: _selected == .uzLatin,
                onTap: () => setState(() => _selected = .uzLatin),
              ),
              LanguageTile(
                title: 'Ўзбек',
                subtitle: 'Кирилл алифбосида',
                isSelected: _selected == .uzCyrillic,
                onTap: () => setState(() => _selected = .uzCyrillic),
              ),
              LanguageTile(
                title: 'Русский',
                subtitle: 'На русском языке',
                isSelected: _selected == .ru,
                onTap: () => setState(() => _selected = .ru),
              ),
              LanguageTile(
                title: 'English',
                subtitle: 'In the Latin alphabet',
                isSelected: _selected == .en,
                onTap: () => setState(() => _selected = .en),
              ),
            ],
          ),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const .all(16),
        child: CustomButton(onTap: () => context.octopus.pushNamed(Routes.login.name), title: 'Davom etish'),
      ),
    ),
  );
}

enum AppLanguage { uzLatin, uzCyrillic, ru, en }

class LanguageTile extends StatelessWidget {
  const LanguageTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 70,
    width: .infinity,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.x.colors.white,
        borderRadius: .circular(16),
        boxShadow: [
          BoxShadow(color: context.x.colors.black.withValues(alpha: 0.08), blurRadius: 56, offset: const Offset(0, 12)),
          BoxShadow(color: context.x.colors.black.withValues(alpha: 0.05), blurRadius: 3, offset: .zero),
        ],
      ),
      child: Material(
        color: context.x.colors.white,
        borderRadius: .circular(16),
        type: .transparency,

        child: InkWell(
          borderRadius: .circular(16),
          onTap: onTap,
          child: Padding(
            padding: const .symmetric(horizontal: 16, vertical: 10),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: context.x.textStyle.sfW700s16.copyWith(color: context.x.colors.black),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
                      ),
                    ],
                  ),
                ),
                _SelectionIndicator(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 24,
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: isSelected
          ? DecoratedBox(
              key: const ValueKey('selected'),
              decoration: BoxDecoration(color: context.x.colors.primary, shape: .circle),
              child: Center(child: Icon(Icons.check_rounded, size: 20, color: context.x.colors.white)),
            )
          : const SizedBox(key: ValueKey('unselected')),
    ),
  );
}
