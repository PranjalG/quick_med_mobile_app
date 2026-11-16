import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// Lets [GoogleMap] receive pan/zoom gestures when nested in a [ScrollView].
final Set<Factory<OneSequenceGestureRecognizer>> mapScrollGestures = {
  Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
};
