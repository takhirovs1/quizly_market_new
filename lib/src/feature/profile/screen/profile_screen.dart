import 'package:flutter/material.dart';

import '../../../common/extension/context_extension.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.x.colors.scaffoldBackground,
    body: Center(child: Text('Profile: ${context.x.dependencies.metadata.appVersion}')),
  );
}
