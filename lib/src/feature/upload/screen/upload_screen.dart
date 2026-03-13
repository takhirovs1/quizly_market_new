import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    body: const Center(child: Text('Upload')),
  );
}
