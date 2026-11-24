import 'package:cards_against_humanity/core/errors/exceptions.dart';

/// Semantic-like app version entity split into numeric parts and optional suffix.
class AppVersion implements Comparable<AppVersion> {
  /// Major version number.
  final int major;

  /// Minor version number.
  final int minor;

  /// Patch version number.
  final int patch;

  /// Optional pre-release or build metadata after the leading `-` separator.
  final String? additionalInfo;

  const AppVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.additionalInfo,
  });

  /// Parses [raw] by splitting on the first two `.` separators and optional `-` suffix.
  ///
  /// E.g. `"1.7.34-beta3"` ---> `"1"` , `"7"`, `"34"` and `"beta3"`
  ///
  /// Throws [VersionParseException] if [raw] does not match `<major>.<minor>.<patch>[-info]`.
  factory AppVersion.parse(String raw) {
    final trimmed = raw.trim();
    final firstDot = trimmed.indexOf('.');
    if (firstDot == -1) {
      throw VersionParseException('Invalid version format: "$raw"');
    }

    final secondDot = trimmed.indexOf('.', firstDot + 1);
    if (secondDot == -1) {
      throw VersionParseException('Invalid version format: "$raw"');
    }

    final majorStr = trimmed.substring(0, firstDot);
    final minorStr = trimmed.substring(firstDot + 1, secondDot);
    final rest = trimmed.substring(secondDot + 1);

    final dashIndex = rest.indexOf('-');
    final String patchStr;
    final String? additionalInfo;

    if (dashIndex == -1) {
      patchStr = rest;
      additionalInfo = null;
    } else {
      patchStr = rest.substring(0, dashIndex);
      final suffix = rest.substring(dashIndex + 1);
      if (suffix.isEmpty) {
        throw VersionParseException('Empty additional version info in: "$raw"');
      }
      additionalInfo = suffix;
    }

    final digitsOnly = RegExp(r'^\d+$');
    if (!digitsOnly.hasMatch(majorStr) ||
        !digitsOnly.hasMatch(minorStr) ||
        !digitsOnly.hasMatch(patchStr)) {
      throw VersionParseException('Non-numeric version component in: "$raw"');
    }

    return AppVersion(
      major: int.parse(majorStr),
      minor: int.parse(minorStr),
      patch: int.parse(patchStr),
      additionalInfo: additionalInfo,
    );
  }

  /// Compares by [major], [minor], [patch], then [additionalInfo] (present > absent).
  @override
  int compareTo(AppVersion other) {
    final majorCmp = major.compareTo(other.major);
    if (majorCmp != 0) return majorCmp;

    final minorCmp = minor.compareTo(other.minor);
    if (minorCmp != 0) return minorCmp;

    final patchCmp = patch.compareTo(other.patch);
    if (patchCmp != 0) return patchCmp;

    final info = additionalInfo;
    final otherInfo = other.additionalInfo;
    if (info == null && otherInfo == null) return 0;
    if (info != null && otherInfo == null) return 1;
    if (info == null && otherInfo != null) return -1;
    return info!.compareTo(otherInfo!);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersion &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch &&
          additionalInfo == other.additionalInfo;

  @override
  int get hashCode => Object.hash(major, minor, patch, additionalInfo);

  /// Whether this version is older than [other].
  bool operator <(AppVersion other) => compareTo(other) < 0;

  /// Whether this version is newer than [other].
  bool operator >(AppVersion other) => compareTo(other) > 0;

  /// Whether this version is older than or equal to [other].
  bool operator <=(AppVersion other) => compareTo(other) <= 0;

  /// Whether this version is newer than or equal to [other].
  bool operator >=(AppVersion other) => compareTo(other) >= 0;

  @override
  String toString() => additionalInfo == null
      ? '$major.$minor.$patch'
      : '$major.$minor.$patch-$additionalInfo';
}
