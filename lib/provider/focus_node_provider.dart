import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart'; // ✅ Needed for Provider.autoDispose

final inputBoxFocusNodeProvider = Provider.autoDispose<FocusNode>((ref) {
  final node = FocusNode();
  ref.onDispose(() => node.dispose());
  return node;
});
