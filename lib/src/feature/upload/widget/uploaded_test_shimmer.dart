import 'package:ui/ui.dart';

class UploadedTestShimmer extends StatelessWidget {
  const UploadedTestShimmer({super.key});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const .symmetric(horizontal: 16, vertical: 8),
    itemCount: 4,
    separatorBuilder: (_, _) => const SizedBox(height: 12),
    itemBuilder: (_, _) => const TestCardShimmer(),
  );
}
