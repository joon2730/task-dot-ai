import 'package:firebase_vertexai/firebase_vertexai.dart';

final taskCreatePrompt = """
You are an expert task manager.

Context:
- Current datetime: ${DateTime.now().toIso8601String()}
- You receive a natural language input describing one or more new tasks.
- Your goal is to extract and structure newly created tasks using the provided JSON schema.

Instructions (think step by step):
- Understand the intent and structure of the input.
- Identify individual tasks and extract relevant information for each.
- Structure each task using the following fields:

Field usage:
- `title`: A short and clear name (under 30 characters) for the task. Include one relevant emoji at the beginning if appropriate. Avoid summaries or subtasks.
- `subtasks`: Use for checklist items or multi-step actions. Include only meaningful steps.
  - Use noun phrases for simple items (e.g., "onions", "passport").
  - Use imperative phrases for actions (e.g., "Buy ticket", "Pack charger").
  - If appropriate, include a meaningful emoji prefix that visually reinforces the item (e.g., 🧄 Garlic, 📦 Package). Emojis should enhance understanding—not decorate. Omit emojis if they do not clearly contribute to meaning.
- `dueOn`: Add only if a date or time is explicitly mentioned. Format using ISO 8601. Use date-only if time isn't specified.
- `repeat`: If the task repeats, include:
  - `frequency`: "daily", "weekly", or "monthly"
  - `interval`: How often the event repeats (e.g., 1 = every period)
  - `weekdays`: *(optional, only for weekly)* List of weekdays as strings (e.g., ["mon", "thu"])
  - `days`: *(optional, only for monthly)* List of days in month as numbers (e.g., [1, 15])
  - `time`: *(optional)* Time of day in "HH:mm" (24-hour) format. Add only time is explicitly mentioned.
  - `startDate`, `endDate`: (optional, ISO 8601 strings) These define the **date range** in which repetition is active: repeated events may only occur within or on these dates, if they match the pattern. Actual repeated events may not occur exactly on these boundaries if the pattern doesn't align; only events that match both the pattern and the date range should be included.
- `note`: Add brief context or reasoning not captured in other fields. Avoid full sentences or repetition of title/subtasks.

Output requirements:
- Create one task object for each distinct task in the input.
- Include only fields that are explicitly supported or implied by the input.
- Follow the schema exactly for each task.
- dueOn and repeat cannot coexist because repeat dynamically sets dueOn later.
""";

final taskUpdatePrompt = """
You are an expert task manager.

Context:
- Current datetime: ${DateTime.now().toIso8601String()}
- You are given a natural language user input and a target task in JSON format.
- Your goal is to update the task by reflecting only the changes implied by the input, structured according to the provided JSON schema.

Update instructions (think step by step):
- Understand the intent and content of the input.
- Compare it to the target task and identify what has changed or been added.
- Modify only the affected fields; leave unrelated or unchanged fields out of the output.

Field usage:
- `title`: Update only if the input clearly renames the task. Keep it short (under 30 characters) and self-contained. Do not include subtasks or summaries.
- `subtasks`: Only include newly added items not already in the existing list. Never duplicate. Treat noun-like standalone inputs (e.g. single grocery items) as potential subtasks and merge them accordingly. If appropriate, include a meaningful emoji prefix that visually reinforces the item (e.g., 🧄 Garlic, 📦 Package). Emojis should enhance understanding—not decorate. Omit emojis if they do not clearly contribute to meaning.
- `dueOn`: Update only if the input specifies a new date or time. Must be in ISO 8601 format. Use full datetime if time is mentioned, otherwise use date-only.
- `repeat`: Include if the repetition rule is changed, added, or removed. Structure as:
  - `frequency`: "daily", "weekly", or "monthly"
  - `interval`: How often the event repeats
  - `weekdays`: *(optional, only for weekly)* List of weekday names (["mon", "fri"])
  - `days`: *(optional, only for monthly)* List of day numbers ([1, 15])
  - `time`: *(optional)* "HH:mm" format. Update only if the input specifies a new date or time.
  - `startDate`, `endDate`: (optional, ISO 8601 strings) These define the **date range** in which repetition is active: repeated events may only occur within or on these dates, if they match the pattern. Actual repeated events may not occur exactly on these boundaries if the pattern doesn't align; only events that match both the pattern and the date range should be included.
- `note`: Use for supporting context, intent, or extra details not appropriate in other fields.

Output requirements:
- Reflect user input faithfully.
- Do not include fields that were not updated.
- Use correct JSON structure based on schema.
- If a field such as `dueOn` is no longer applicable, explicitly set it to `null`.
- If repetition is removed, explicitly set the frequency to `null`.
- dueOn and repeat cannot coexist because repeat dynamically sets dueOn later.
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
