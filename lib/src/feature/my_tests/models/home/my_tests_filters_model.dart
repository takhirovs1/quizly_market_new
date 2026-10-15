import '../../../../common/extension/number_extension.dart';

/// GET /api/me/tests/filters — the "Barchasi" filter sheet (Figma "B").
/// Each list's counts follow the other filters sent; [total] follows all of them.
class MyTestsFiltersResponse {
  const MyTestsFiltersResponse({
    this.subjects = const <FilterOption>[],
    this.organizations = const <FilterOption>[],
    this.total = 0,
  });

  factory MyTestsFiltersResponse.fromJson(Map<String, Object?> json) {
    final root = json['data'] is Map<String, Object?> ? json['data']! as Map<String, Object?> : json;
    List<FilterOption> parse(String key) => (root[key] as List<Object?>? ?? const <Object?>[])
        .whereType<Map<String, Object?>>()
        .map(FilterOption.fromJson)
        .toList();
    return MyTestsFiltersResponse(
      subjects: parse('subjects'),
      organizations: parse('organizations'),
      total: root['total'].toIntOrNull ?? 0,
    );
  }

  final List<FilterOption> subjects;
  final List<FilterOption> organizations;

  /// Count behind "Natijalarni ko'rsatish (N)".
  final int total;
}

class FilterOption {
  const FilterOption({required this.id, required this.name, required this.count, this.verified, this.avatarUrl});

  factory FilterOption.fromJson(Map<String, Object?> json) => FilterOption(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    count: json['count'].toIntOrNull ?? 0,
    verified: json['verified'] as bool?,
    avatarUrl: json['avatar_url'] as String?,
  );

  final String id;
  final String name;
  final int count;

  /// Organizations only.
  final bool? verified;
  final String? avatarUrl;
}

/// The locally-selected filter state driving GET /me/tests (and /filters).
class MyTestsFilterSelection {
  const MyTestsFilterSelection({
    this.subjectIds = const <String>{},
    this.orgIds = const <String>{},
    this.search = '',
    this.status,
    this.sort = 'last_opened',
  });

  final Set<String> subjectIds;
  final Set<String> orgIds;
  final String search;

  /// not_started | in_progress | completed; null = any.
  final String? status;

  /// last_opened | score | name.
  final String sort;

  /// Filters the sheet applies (subject/org/sort) — the toolbar [search] and
  /// [status] chips sit outside the sheet's Reset.
  bool get hasSheetFilters => subjectIds.isNotEmpty || orgIds.isNotEmpty;

  /// Any active filter, including search and status — drives the "active" dot.
  bool get hasAny => subjectIds.isNotEmpty || orgIds.isNotEmpty || search.isNotEmpty || status != null;

  int get sheetCount => subjectIds.length + orgIds.length;

  MyTestsFilterSelection copyWith({
    Set<String>? subjectIds,
    Set<String>? orgIds,
    String? search,
    String? sort,
  }) => MyTestsFilterSelection(
    subjectIds: subjectIds ?? this.subjectIds,
    orgIds: orgIds ?? this.orgIds,
    search: search ?? this.search,
    status: status,
    sort: sort ?? this.sort,
  );

  /// copyWith that can also clear [status] (pass `clearStatus: true`).
  MyTestsFilterSelection withStatus(String? status) => MyTestsFilterSelection(
    subjectIds: subjectIds,
    orgIds: orgIds,
    search: search,
    status: status,
    sort: sort,
  );

  Map<String, Object?> toQuery({int? page, int? limit}) => <String, Object?>{
    if (subjectIds.isNotEmpty) 'subject_ids': subjectIds.join(','),
    if (orgIds.isNotEmpty) 'org_ids': orgIds.join(','),
    if (search.isNotEmpty) 'q': search,
    if (status != null) 'status': status,
    'sort': sort,
    'page': ?page,
    'limit': ?limit,
  };
}
