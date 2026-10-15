// Shared value enums for the Home sections. These are plain value types (not
// endpoint response models), so they may be reused across section models.
// See docs/home-flow.en.md §3.

/// Session / test mode. Maps `mode` strings from the backend.
enum SessionMode {
  test('test'),
  exam('exam'),
  flashcard('flashcard'),
  random('random'),
  mistakes('mistakes');

  const SessionMode(this.value);

  final String value;

  static SessionMode fromValue(String? value) => switch (value) {
    'test' => test,
    'exam' => exam,
    'flashcard' => flashcard,
    'random' => random,
    'mistakes' => mistakes,
    _ => test,
  };
}

/// Purchased-test lifecycle status (`user_tests.status`, docs §3.1).
enum MyTestStatus {
  notStarted('not_started'),
  inProgress('in_progress'),
  completed('completed');

  const MyTestStatus(this.value);

  final String value;

  static MyTestStatus fromValue(String? value) => switch (value) {
    'not_started' => notStarted,
    'in_progress' => inProgress,
    'completed' => completed,
    _ => notStarted,
  };
}
