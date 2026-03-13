extension NumberExtension on num {
  String get splitPerThree => toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]} ');
}

extension IntX on int {
  /// Format the duration in mm:ss format
  String get formatDuration {
    if (this <= 0) return '0:00';

    final duration = Duration(milliseconds: this);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

extension NumUzs on num {
  String get formatUzs {
    final a = toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (b) => '${b[1]} ');
    return '$a UZS';
  }
}
