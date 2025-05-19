import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';

import 'package:tasket/util/prompt.dart';
import 'package:tasket/model/task_patch.dart';

class AIService {
  final _model = FirebaseVertexAI.instance.generativeModel(
    // model: 'gemini-2.0-flash-lite-001',      // $0.3/1M
    model: 'gemini-2.0-flash-001', // $0.4/1M
    // model: 'gemini-2.5-flash-preview-04-17', // $0.6/1M
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: taskJsonSchema,
    ),
    systemInstruction: Content.system(taskSystemPrompt),
  );

  Future<List<TaskPatch>> generateTaskPatches(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    if (response.text == null) {
      throw Exception('Failed to generate task patch: Response text is null');
    }

    print(response.text); // see raw ai output

    final Map<String, dynamic> parsed = jsonDecode(response.text!);

    final List<Map<String, dynamic>> createList =
        (parsed['create'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final List<Map<String, dynamic>> updateList =
        (parsed['update'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final allPatches = [
      ...createList.map((json) => TaskPatch.fromJson('create', json)),
      ...updateList.map((json) => TaskPatch.fromJson('update', json)),
    ];

    return allPatches;
  }
}
