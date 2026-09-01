import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/util/error_util.dart';
import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../data/upload_repository.dart';
import '../model/test_import_models.dart';

part 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadCubitState> {
  FileUploadCubit({required this.uploadRepository}) : super(const FileUploadCubitState());

  final IUploadRepository uploadRepository;

  /// Runs dry-run validation on the picked file bytes (`POST /api/tests/import?dry_run=true`).
  Future<void> validateFile({
    required List<int> fileBytes,
    required String fileName,
    required String testName,
    String? description,
    String? categoryId,
    int? price,
    bool? isFree,
  }) async {
    emit(state.copyWith(validationStatus: StateStatus.loading, fileName: fileName, fileBytes: fileBytes));
    try {
      final dryRun = await uploadRepository.importDryRun(
        fileBytes: fileBytes,
        fileName: fileName,
        name: testName.isNotEmpty ? testName : fileName,
        description: description,
        categoryId: categoryId,
        price: price,
        isFree: isFree,
      );

      emit(
        state.copyWith(
          validationStatus: StateStatus.success,
          dryRunResult: dryRun,
          errors: dryRun.errors,
          warnings: dryRun.warnings,
          questionCount: dryRun.questionCount,
        ),
      );
    } on Object catch (e, s) {
      info('VALIDATE FILE DRY RUN ERROR: $e $s');
      emit(state.copyWith(validationStatus: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(e)));
    }
  }

  /// Performs actual file import (`POST /api/tests/import`).
  Future<void> submitImport({
    required String testName,
    String? description,
    String? categoryId,
    int? price,
    bool? isFree,
  }) async {
    if (state.fileBytes == null || state.fileName == null) return;
    emit(state.copyWith(importStatus: StateStatus.loading));
    try {
      final result = await uploadRepository.importTest(
        fileBytes: state.fileBytes!,
        fileName: state.fileName!,
        name: testName,
        description: description,
        categoryId: categoryId,
        price: price,
        isFree: isFree,
      );

      emit(state.copyWith(importStatus: StateStatus.success, importResult: result));
    } on Object catch (e, s) {
      info('SUBMIT FILE IMPORT ERROR: $e $s');
      emit(state.copyWith(importStatus: StateStatus.error, errorMessage: ErrorUtil.toUserFriendlyMessage(e)));
    }
  }

  void clearFile() {
    emit(const FileUploadCubitState());
  }
}
