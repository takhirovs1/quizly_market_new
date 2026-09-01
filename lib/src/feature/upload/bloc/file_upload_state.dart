part of 'file_upload_cubit.dart';

class FileUploadCubitState extends Equatable {
  const FileUploadCubitState({
    this.validationStatus = StateStatus.idle,
    this.importStatus = StateStatus.idle,
    this.fileName,
    this.fileBytes,
    this.dryRunResult,
    this.errors = const [],
    this.warnings = const [],
    this.questionCount = 0,
    this.importResult,
    this.errorMessage,
  });

  final StateStatus validationStatus;
  final StateStatus importStatus;
  final String? fileName;
  final List<int>? fileBytes;
  final TestImportDryRunResponse? dryRunResult;
  final List<ImportRowError> errors;
  final List<String> warnings;
  final int questionCount;
  final TestImportResponse? importResult;
  final String? errorMessage;

  bool get hasFile => fileName != null && fileBytes != null;
  bool get hasErrors => errors.isNotEmpty;
  bool get isValid => hasFile && errors.isEmpty && validationStatus.isSuccess;

  FileUploadCubitState copyWith({
    StateStatus? validationStatus,
    StateStatus? importStatus,
    String? fileName,
    List<int>? fileBytes,
    TestImportDryRunResponse? dryRunResult,
    List<ImportRowError>? errors,
    List<String>? warnings,
    int? questionCount,
    TestImportResponse? importResult,
    String? errorMessage,
  }) => FileUploadCubitState(
    validationStatus: validationStatus ?? this.validationStatus,
    importStatus: importStatus ?? this.importStatus,
    fileName: fileName ?? this.fileName,
    fileBytes: fileBytes ?? this.fileBytes,
    dryRunResult: dryRunResult ?? this.dryRunResult,
    errors: errors ?? this.errors,
    warnings: warnings ?? this.warnings,
    questionCount: questionCount ?? this.questionCount,
    importResult: importResult ?? this.importResult,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    validationStatus,
    importStatus,
    fileName,
    fileBytes,
    dryRunResult,
    errors,
    warnings,
    questionCount,
    importResult,
    errorMessage,
  ];
}
