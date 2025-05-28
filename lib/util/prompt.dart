import 'package:firebase_vertexai/firebase_vertexai.dart';

final taskCreatePrompt = """
You are an expert task manager.

Context:
- Current datetime: ${DateTime.now().toIso8601String()}
- You receive a natural language input describing one or more new tasks.
- Your goal is to extract and structure newly created tasks using the provided JSON schema.

Instructions (step by step):
- Understand the intent and structure of the input.
- Identify individual tasks and extract relevant information for each.
- Structure each task using the following fields:

Field usage:
- title: A short and clear name (under 30 characters). Add a relevant emoji at the beginning if appropriate. Do not use summaries or include subtasks here.
- subtasks: Only include actionable checklist steps or tasks the user can actually do or complete. Do not include event info, location, schedule details, or any descriptive text. Subtasks should be things the user can check off, such as "Buy ticket" or "Pack charger," not informational content.
- dueOn: Add only if a date or time is explicitly mentioned. Use ISO 8601 format. Use date-only if time is not specified.
- repeat: If the task repeats, include:
  - frequency: "daily", "weekly", or "monthly"
  - interval: How often the event repeats (e.g., 1 = every period)
  - weekdays: (weekly only) List of weekdays as strings (e.g., ["mon", "thu"])
  - days: (monthly only) List of days in the month as numbers (e.g., [1, 15]); use -1 for the last day
  - time: (optional, "HH:mm" (24-hour) format) Time at the repeated days, use when time is mentioned.
  - startDate: (optional, ISO 8601) Start of repeat range
  - endDate: (optional, ISO 8601) End of repeat range
- note: Use this field for any detailed information, such as location, address, contact info, or descriptive/contextual text that is not expressed in other fields. use \n for line break.

Output requirements:
- Create one task object for each distinct task in the input.
- Only include fields supported or implied by the input.
- Reflect user input faithfully; use the note field for all extra details, info, or descriptions that are not actionable.
- Follow the schema exactly for each task.
- dueOn and repeat cannot coexist (repeat sets dueOn dynamically).
- If user describes repetition "during [a month]" or "during [multiple months]", infer:
  - startDate: First day of the first mentioned month (e.g., 2025-06-01)
  - endDate: Last day of the last mentioned month (e.g., 2025-07-31)
  Use these values in the repeat object.
""";

final taskUpdatePrompt = """
You are an expert task manager.

Context:
- Current datetime: ${DateTime.now().toIso8601String()}
- You are given a natural language user input and a target task in JSON format.
- Your goal is to update the task by reflecting only the changes implied by the input, structured according to the provided JSON schema.

Update instructions (step by step):
- Understand the intent and content of the input.
- Compare to the target task; identify changed or added fields.
- Modify only the affected fields. Leave unrelated or unchanged fields out.

Field usage:
- title: Update only if the input clearly renames the task. Keep it short (under 30 characters) and self-contained. Do not include subtasks or summaries here.
- subtasks: Only include newly added actionable checklist steps that are not already in the list. Never duplicate. Do not include event info, location, schedule details, or any descriptive text. Subtasks should be things the user can check off, not informational content.
- dueOn: Update only if the input specifies a new date or time. Use ISO 8601 format. Use date-only if time is not specified.
- repeat: Include if the repetition rule is changed, added, or removed. Structure as
  - frequency: "daily", "weekly", or "monthly"
  - interval: How often the event repeats
  - weekdays: (weekly only) List of weekday names (e.g., ["mon", "fri"])
  - days: (monthly only) List of day numbers (e.g., [1, 15]); use -1 for last day
  - time: (optional, "HH:mm" (24-hour) format) Time at the repeated days, use when time is mentioned. Can be used with any frequency.
  - startDate: (optional, ISO 8601) Start of repeat range
  - endDate: (optional, ISO 8601) End of repeat range
    - If user describes repetition "during [a month]" or "during [multiple months]", infer:
      - startDate: First day of the first mentioned month (e.g., 2025-06-01)
      - endDate: Last day of the last mentioned month (e.g., 2025-07-31)
      Use these values in the repeat object.
- note: Use this field for any summarized detailed information, such as location, address, contact info, or descriptive/contextual text that is not expressed in other fields. use \n for line break

Output requirements:
- Reflect user input faithfully; use the note field for all extra details, info, or descriptions that are not actionable.
- Do not include fields that were not updated.
- Use correct JSON structure based on schema.
- If a field such as dueOn is no longer applicable, explicitly set it to null.
- If repetition is removed, explicitly set the frequency to null.
- dueOn and repeat cannot coexist (repeat sets dueOn dynamically).
""";

final taskProperties = {
  'title': Schema.string(),
  'dueOn': Schema.string(),
  'subtasks': Schema.array(items: Schema.string()),
  'note': Schema.string(),
  'repeat': Schema.object(
    properties: {
      'frequency': Schema.enumString(
        enumValues: ["daily", "weekly", "monthly", "null"],
      ),
      'interval': Schema.integer(),
      'weekdays': Schema.array(
        items: Schema.enumString(
          enumValues: ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
        ),
      ),
      'days': Schema.array(items: Schema.integer()),
      'time': Schema.string(),
      'startDate': Schema.string(),
      'endDate': Schema.string(),
    },
    optionalProperties: [
      'interval',
      'weekdays',
      'days',
      'time',
      'startDate',
      'endDate',
    ],
  ),
};

final taskCreateSchema = Schema.array(
  items: Schema.object(
    properties: taskProperties,
    optionalProperties: ['dueOn', 'subtasks', 'note', 'repeat'],
  ),
);

final taskUpdateSchema = Schema.array(
  items: Schema.object(
    properties: taskProperties,
    optionalProperties: ['title', 'dueOn', 'subtasks', 'note', 'repeat'],
  ),
);
