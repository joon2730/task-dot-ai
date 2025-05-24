import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';

import 'package:tasket/util/prompt.dart';

class AIService {
  final _createTaskModel = FirebaseVertexAI.instance.generativeModel(
    // model: 'gemini-2.0-flash-lite-001', // $0.3/1M
    model: 'gemini-2.0-flash-001', // $0.4/1M
    // model: 'gemini-2.5-flash-preview-04-17', // $0.6/1M
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: taskCreateSchema,
      maxOutputTokens: 1024,
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
    ),
    systemInstruction: Content.system(taskUpdatePrompt),
  );

  Future<List<Map<String, dynamic>>> createTasks(String prompt) async {
    print(prompt);

    final response = await _createTaskModel.generateContent([
      Content.text(prompt),
    ]);

    print(response.text); // see raw ai output

    final List<dynamic> decoded = jsonDecode(response.text!);
    final List<Map<String, dynamic>> parsed =
        decoded.cast<Map<String, dynamic>>();

    return parsed;
  }

  Future<List<Map<String, dynamic>>> updateTask(
    String prompt,
    String taskJson,
  ) async {
    print(prompt);

    final response = await _updateTaskModel.generateContent([
      Content.text({"input": prompt, "task": taskJson}.toString()),
    ]);
    if (response.text == null) {
      throw Exception('Failed to generate task patch: Response text is null');
    }

    print(response.text); // see raw ai output

    final List<dynamic> decoded = jsonDecode(response.text!);
    final List<Map<String, dynamic>> parsed =
        decoded.cast<Map<String, dynamic>>();

    return parsed;
  }
}
