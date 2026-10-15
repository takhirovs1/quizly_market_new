import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/util/logger.dart';
import '../../../common/util/state_status.dart';
import '../data/home_repository.dart';
import '../models/home/my_tests_filters_model.dart';
import '../models/home/my_tests_preview_model.dart';

/// State for the "Barchasi" My-tests list + filter sheet (Figma "B").
class AllTestsState extends Equatable {
  const AllTestsState({
    this.status = StateStatus.loading,
    this.items = const <MyTestPreviewItem>[],
    this.counts = const MyTestsStatusCounts(),
    this.selection = const MyTestsFilterSelection(),
    this.options = const MyTestsFiltersResponse(),
    this.error,
  });

  final StateStatus status;
  final List<MyTestPreviewItem> items;
  final MyTestsStatusCounts counts;
  final MyTestsFilterSelection selection;
  final MyTestsFiltersResponse options;
  final String? error;

  AllTestsState copyWith({
    StateStatus? status,
    List<MyTestPreviewItem>? items,
    MyTestsStatusCounts? counts,
    MyTestsFilterSelection? selection,
    MyTestsFiltersResponse? options,
    String? error,
  }) => AllTestsState(
    status: status ?? this.status,
    items: items ?? this.items,
    counts: counts ?? this.counts,
    selection: selection ?? this.selection,
    options: options ?? this.options,
    error: error,
  );

  @override
  List<Object?> get props => [status, items, counts, selection, options, error];
}

class AllTestsCubit extends Cubit<AllTestsState> {
  AllTestsCubit({required this.repository}) : super(const AllTestsState());

  final IHomeRepository repository;

  Future<void> load() async {
    emit(state.copyWith(status: StateStatus.loading, error: null));
    await _reload();
  }

  Future<void> _reload() async {
    try {
      final page = await repository.getMyTests(state.selection);
      emit(state.copyWith(status: StateStatus.success, items: page.items, counts: page.counts));
    } on Object catch (e, s) {
      info('ALL TESTS LOAD ERROR: $e $s');
      emit(state.copyWith(status: StateStatus.error, error: e.toString()));
    }
  }

  /// Loads the subject/organization options (with counts) for the filter sheet.
  Future<void> loadFilters() async {
    try {
      final options = await repository.getMyTestsFilters(state.selection);
      emit(state.copyWith(options: options));
    } on Object catch (e, s) {
      info('ALL TESTS FILTERS LOAD ERROR: $e $s');
    }
  }

  void setSearch(String query) {
    if (query == state.selection.search) return;
    emit(state.copyWith(selection: state.selection.copyWith(search: query)));
    _reload();
  }

  void setStatus(String? status) {
    emit(state.copyWith(selection: state.selection.withStatus(status)));
    _reload();
  }

  /// Applies the sheet's subject/org/sort choices (toolbar search/status kept).
  void applyFilters(MyTestsFilterSelection next) {
    emit(state.copyWith(selection: next, status: StateStatus.loading));
    _reload();
  }

  void removeSubject(String id) =>
      applyFilters(state.selection.copyWith(subjectIds: {...state.selection.subjectIds}..remove(id)));

  void removeOrg(String id) => applyFilters(state.selection.copyWith(orgIds: {...state.selection.orgIds}..remove(id)));

  /// Clears the sheet filters (subject/org), keeping search and status.
  void clearSheetFilters() =>
      applyFilters(state.selection.copyWith(subjectIds: const <String>{}, orgIds: const <String>{}));
}
