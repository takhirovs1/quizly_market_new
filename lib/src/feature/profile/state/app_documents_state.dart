import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../common/extension/context_extension.dart';
import '../screen/app_documents_screen.dart';

abstract class AppDocumentsState extends State<AppDocumentsScreen> {
  String termsOfUseMarkdown = '';
  String privacyPolicyMarkdown = '';
  bool isLoadingTerms = true;
  bool isLoadingPrivacy = true;
  String? termsError;
  String? privacyError;

  @override
  void initState() {
    context.setupTelegramBackButton();
    super.initState();
    loadDocuments();
  }

  @override
  void dispose() {
    context.teardownTelegramBackButton();
    super.dispose();
  }

  void loadDocuments() {
    final repository = context.x.dependencies.repository.profileRepository;

    setState(() {
      isLoadingTerms = true;
      termsError = null;
    });
    repository
        .getDocument('terms_of_use')
        .then((value) {
          if (!mounted) return;
          setState(() {
            termsOfUseMarkdown = value;
            isLoadingTerms = false;
            termsError = null;
          });
        })
        .catchError((Object error) {
          if (!mounted) return;
          setState(() {
            isLoadingTerms = false;
            termsError = error.toString();
          });
        });

    setState(() {
      isLoadingPrivacy = true;
      privacyError = null;
    });
    repository
        .getDocument('privacy_policy')
        .then((value) {
          if (!mounted) return;
          setState(() {
            privacyPolicyMarkdown = value;
            isLoadingPrivacy = false;
            privacyError = null;
          });
        })
        .catchError((Object error) {
          if (!mounted) return;
          setState(() {
            isLoadingPrivacy = false;
            privacyError = error.toString();
          });
        });
  }

  MarkdownStyleSheet markdownStyle(BuildContext context) => MarkdownStyleSheet(
    p: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text, height: 1.5),
    h1: context.x.textStyle.sfW700s18.copyWith(color: context.x.colors.text),
    h2: context.x.textStyle.sfW700s16.copyWith(color: context.x.colors.text),
    h3: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.text),
    strong: context.x.textStyle.sfW600s16.copyWith(color: context.x.colors.text),
    em: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text, fontStyle: FontStyle.italic),
    listBullet: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.text),
    a: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.primary, decoration: TextDecoration.underline),
    blockquote: context.x.textStyle.sfW400s14.copyWith(color: context.x.colors.gray),
    blockSpacing: 12,
    listIndent: 24,
  );
}
