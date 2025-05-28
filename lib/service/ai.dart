import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

import 'package:tasket/util/prompt.dart';
import 'package:tasket/util/exception.dart';

class AIService {
  final String userId;

  AIService({required this.userId});

  final _createTaskModel = FirebaseVertexAI.instance.generativeModel(
    // model: 'gemini-2.0-flash-lite-001', // $0.3/1M
    model: 'gemini-2.0-flash-001', // $0.4/1M
    // model: 'gemini-2.5-flash-preview-04-17', // $0.6/1M
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: taskCreateSchema,
      maxOutputTokens: 1024,
      temperature: 0.1,
    ),
    systemInstruction: Content.system(taskCreatePrompt),
  );

  final _updateTaskModel = FirebaseVertexAI.instance.generativeModel(
    // model: 'gemini-2.0-flash-lite-001', // $0.3/1M
    model: 'gemini-2.0-flash-001', // $0.4/1M
    // model: 'gemini-2.5-flash-preview-04-17', // $0.6/1M
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: taskUpdateSchema,
      maxOutputTokens: 1024,
      temperature: 0.1,
    ),
    systemInstruction: Content.system(taskUpdatePrompt),
  );

  Future<void> _checkAndUpdateAICallCount() async {
    final usageDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!usageDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'aiCallCount': 1,
        'lastAICallDate': FieldValue.serverTimestamp(),
      });
      return;
    }
    final usageData = usageDoc.data();
    final Timestamp? lastCall = usageData?['lastAICallDate'];
    final DateTime today = DateTime.now();
    final DateTime lastCallDate =
        lastCall?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bool isSameDay =
        today.year == lastCallDate.year &&
        today.month == lastCallDate.month &&
        today.day == lastCallDate.day;

    final aiCallCount = isSameDay ? (usageData?['aiCallCount'] ?? 0) : 0;
    const aiCallLimit = 300;

    if (aiCallCount >= aiCallLimit) {
      throw AiException(
        'Daily AI call limit reached: $aiCallCount/$aiCallLimit',
      );
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'aiCallCount': FieldValue.increment(1),
      'lastAICallDate': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> createTasks(String prompt) async {
    await _checkAndUpdateAICallCount();
    final response = await _createTaskModel.generateContent([
      Content.text(prompt),
    ]);

    if (response.text == null) {
      throw AiException('No response from AI. Please retry.');
    }

    final List<dynamic> decoded = jsonDecode(response.text!);
    final List<Map<String, dynamic>> parsed =
        decoded.cast<Map<String, dynamic>>();

    if (parsed.isEmpty) {
      throw AiException('No task created. Please retry.');
    }

    return parsed;
  }

  Future<List<Map<String, dynamic>>> updateTask(
    String prompt,
    String taskJson,
  ) async {
    await _checkAndUpdateAICallCount();
    final response = await _updateTaskModel.generateContent([
      Content.text({"input": prompt, "target": taskJson}.toString()),
    ]);

    if (response.text == null) {
      throw AiException('No response from AI. Please retry.');
    }

    final List<dynamic> decoded = jsonDecode(response.text!);
    final List<Map<String, dynamic>> parsed =
        decoded.cast<Map<String, dynamic>>();

    if (parsed.isEmpty) {
      throw AiException('No update generated. Please retry.');
    }
    return parsed;
  }
}
