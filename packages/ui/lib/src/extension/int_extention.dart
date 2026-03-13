extension FromSecondsToHHMM on int {
  String get fromSecondsToHHMM {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = this ~/ 3600;
    final minutes = (this % 3600) ~/ 60;

    return '${twoDigits(hours)}:${twoDigits(minutes)}';
  }

  String get fromSecondsToHHMMSS {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = this ~/ 3600;
    final minutes = (this % 3600) ~/ 60;
    final seconds = this % 60;

    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
