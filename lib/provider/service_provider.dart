import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tasket/service/auth.dart';
import 'package:tasket/service/data.dart';
import 'package:tasket/service/ai.dart';

final authServiceProvider = Provider((ref) => AuthService());

final userStreamProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).userStream;
});

final dataServiceProvider = Provider<DataService?>((ref) {
  final user = ref.watch(userStreamProvider).value;
  return (user != null) ? DataService(userId: user.uid) : null;
});

final aiServiceProvider = Provider<AIService>((ref) => AIService());
