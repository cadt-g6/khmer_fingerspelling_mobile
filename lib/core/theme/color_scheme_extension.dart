import 'package:flutter/material.dart';
import 'package:khmer_fingerspelling_flutter/core/theme/m3_read_only_color.dart';

extension ColorSchemeExtension on ColorScheme {
  M3ReadOnlyColor get readOnly => M3ReadOnlyColor(this);
}
