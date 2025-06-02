// import 'package:firebase_vertexai/firebase_vertexai.dart';

final taskCreatePrompt = """
You are an expert task manager.

Context:
- Current datetime: ${DateTime.now().toIso8601String()}
- You receive a natural language input describing one or more new tasks.
- Your goal is to extract and structure exactly one new task as a single JSON object.

Instructions (step by step):
1. Identify the first distinct task in the user’s input.
2. Extract and structure it with only these fields in a single JSON object:
   {
     "title": "<string, max 30 chars, emoji prefix if appropriate>",
     "subtasks": [ "<string>", … ],              // actionable checklist items, empty array if none
     "dueOn": "<ISO-8601 date or date-time>",    // omit if not specified
     "repeat": {                                 // omit if not repeating
       "frequency": "daily"|"weekly"|"monthly",
       "interval": <number>,
       "weekdays": [ "mon", "tue", ... ],        // weekly only
       "days": [ <number>, ... ],                 // monthly only, -1 = last day
       "time": "HH:mm",                          // optional if time given
       "startDate": "<YYYY-MM-DD>",               // optional, if repetition is limited to some months
       "endDate": "<YYYY-MM-DD>"
     },
     "priority": -1|1,                            // optional; only include if not 0 (default)
     "note": "<string>"                          // extra details, omit if none
   }

Field usage:
- title: concise and clear, ≤30 characters; add emoji if fitting.
- subtasks: checklist actionable steps only, no dates or descriptions.
- dueOn: date or datetime only if explicitly mentioned.
- repeat: only if user states repetition; include all relevant keys.
- priority: -1 = low, 0 = normal (default), 1 = top; infer based on urgency or keywords like "important", "low priority", etc.; omit if 0.
- note: any other descriptive/contextual info; use '\\n' for newlines.

Output requirements:
- Output exactly one JSON object, no array or extra keys.
- Omit fields that do not apply.
- No commentary or markdown, only valid JSON.
""";

final taskUpdatePrompt = """
You are an expert task manager.

Context:
- Current datetime: ${DateTime.now().toIso8601String()}
- You are given:
  1. A natural language input describing updates.
  2. A target task JSON object.
- Your goal is to output a JSON object reflecting **only the changes** implied by the input.

Update instructions (step by step):
1. Understand the user's update intent.
2. Compare input to the target task; identify fields that changed or must be added.
3. Output a JSON object with **only the changed fields**.
4. If a field is removed or no longer applies, set its value to null.
5. If repetition is removed, set `"frequency": null` inside the repeat object.
6. dueOn and repeat cannot coexist; repeat controls dynamic due dates.
7. Output exactly one JSON object—no arrays, no extra keys, no commentary.

Field usage:
- title: update only if clearly renamed; ≤30 characters, no subtasks or summaries here.
- subtasks: include only new actionable checklist items not already present; do not duplicate.
- dueOn: update only if a new explicit date/time is specified.
- repeat: include if repetition is changed, added, or removed; structure with:
  {
    "frequency": "daily"|"weekly"|"monthly"|null,
    "interval": <number>,
    "weekdays": [ "mon", "tue", ... ],  // weekly only
    "days": [ <number>, ... ],           // monthly only, -1 = last day
    "time": "HH:mm",                    // optional if time changed
    "startDate": "<YYYY-MM-DD>",         // optional
    "endDate": "<YYYY-MM-DD>"
  }
- priority: update if urgency changes; use -1 for low, 0 for normal, 1 for top; set to null if priority removed.
- note: any extra descriptive or contextual info; use '\\n' for newlines.

Output requirements:
- Reflect input changes faithfully.
- Omit unchanged fields.
- Set removed fields explicitly to null.
- Valid JSON only, no commentary.
""";

// final taskProperties = {
//   'title': Schema.string(),
//   'dueOn': Schema.string(),
//   'subtasks': Schema.array(items: Schema.string()),
//   'note': Schema.string(),
//   'repeat': Schema.object(
//     properties: {
//       'frequency': Schema.enumString(
//         enumValues: ["daily", "weekly", "monthly", "null"],
//       ),
//       'interval': Schema.integer(),
//       'weekdays': Schema.array(
//         items: Schema.enumString(
//           enumValues: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
//         ),
//       ),
//       'days': Schema.array(items: Schema.integer()),
//       'time': Schema.string(),
//       'startDate': Schema.string(),
//       'endDate': Schema.string(),
//     },
//     optionalProperties: [
//       'interval',
//       'weekdays',
//       'days',
//       'time',
//       'startDate',
//       'endDate',
//     ],
//   ),
// });

// final taskCreateSchema = Schema.array(
//   items: Schema.object(
//     properties: taskProperties,
//     optionalProperties: ['dueOn', 'subtasks', 'note', 'repeat'],
//   ),
// );

// final taskUpdateSchema = Schema.array(
//   items: Schema.object(
//     properties: taskProperties,
//     optionalProperties: ['title', 'dueOn', 'subtasks', 'note', 'repeat'],
//   ),
// );
