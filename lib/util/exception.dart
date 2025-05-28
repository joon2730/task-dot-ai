import 'package:flutter/material.dart';

import 'package:tasket/util/alert.dart';

abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class AiException extends AppException {
  AiException(super.message);
}

class DataException extends AppException {
  DataException(super.message);
}

void handleException(
  BuildContext context,
  Object error, {
  String defaultMessage = 'Something went wrong.',
}) {
  final message = error is AppException ? error.message : defaultMessage;
  // print(error);

  showErrorAlert(context, message);
}
