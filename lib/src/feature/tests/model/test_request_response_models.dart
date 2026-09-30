class TestDetailRequest {
  const TestDetailRequest({this.shuffle, this.range, this.demo});

  final String? shuffle;
  final String? range;
  final bool? demo;

  Map<String, Object?> toJson() => {
    if (shuffle != null) 'shuffle': shuffle,
    if (range != null) 'range': range,
    if (demo != null) 'demo': demo,
  };
}

class StartAttemptRequest {
  const StartAttemptRequest({required this.mode});

  final String mode;

  Map<String, Object?> toJson() => {'mode': mode};
}

class StartAttemptResponse {
  const StartAttemptResponse({required this.attemptId});

  factory StartAttemptResponse.fromJson(Map<String, Object?> json) {
    final data = json['data'] as Map<String, Object?>? ?? {};
    return StartAttemptResponse(attemptId: data['id']?.toString() ?? '');
  }

  final String attemptId;
}

class FinishAttemptRequest {
  const FinishAttemptRequest({required this.answers, required this.timeSpentSec, required this.skipCount});

  final List<Map<String, String>> answers;
  final int timeSpentSec;
  final int skipCount;

  Map<String, Object?> toJson() => {'answers': answers, 'time_spent_sec': timeSpentSec, 'skip_count': skipCount};
}

class FinishAttemptResponse {
  const FinishAttemptResponse();

  factory FinishAttemptResponse.fromJson(Map<String, Object?> json) => const FinishAttemptResponse();
}
