// import 'package:ui/ui.dart';

// import '../../../common/extension/context_extension.dart';
// import '../models/test_model.dart';

// class MyTestItemWidget extends StatelessWidget {
//   const MyTestItemWidget({required this.test, super.key});
//   final TestModel test;

//   @override
//   Widget build(BuildContext context) => Column(
//     children: [
//       Row(
//         children: [
//           Flexible(
//             child: Text(test.name ?? '', style: context.x.textStyle.sfW500s16, maxLines: 2, overflow: .ellipsis),
//           ),
//         ],
//       ),
//       const SizedBox(height: 6),
//       for (int i = 0; i < test.answers.length; i++)
//         Padding(
//           padding: const .only(bottom: 6),
//           child: _AnswerItem(answerModel: test.answers[i]),
//         ),

//       const SizedBox(height: 10),
//     ],
//   );
// }

// class _AnswerItem extends StatelessWidget {
//   const _AnswerItem({required this.answerModel});
//   final AnswerModel answerModel;
//   @override
//   Widget build(BuildContext context) => DecoratedBox(
//     decoration: BoxDecoration(
//       color: context.x.colors.cardBackground2,
//       border: Border.all(color: context.x.colors.gray),
//       borderRadius: .circular(8),
//     ),
//     child: SizedBox(
//       width: .infinity,
//       child: Padding(
//         padding: const .symmetric(vertical: 8, horizontal: 10),
//         child: Text(answerModel.text, style: context.x.textStyle.sfW400s16, textAlign: .start),
//       ),
//     ),
//   );
// }
