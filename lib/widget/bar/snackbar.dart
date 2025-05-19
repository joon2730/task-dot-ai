import 'package:flutter/material.dart';

SnackBar topSnackbar(String text) {
  return SnackBar(
    content: Text(text),
    behavior: SnackBarBehavior.fixed,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    // backgroundColor: Colors.redAccent,
  );
}
