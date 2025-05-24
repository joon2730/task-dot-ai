import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:tasket/model/task.dart';
import 'package:tasket/provider/task_provider.dart';
import 'package:tasket/provider/service_provider.dart';

class InputBox extends HookConsumerWidget {
  const InputBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final height = MediaQuery.of(context).size.height;
    final isInputEmpty = useState(true);
    final isLoading = useState(false);
    final isFocused = useState(false);
    final inputAction = useState("create");

    Future<void> handleSubmit() async {
      final inputText = controller.text;
      FocusScope.of(context).unfocus();
      isLoading.value = true;

      if (ref.read(selectedTaskProvider) == null) {
        // generate new task
        final output = await ref.read(aiServiceProvider).createTasks(inputText);
        // create task (no id given)
        final List<Task> tasks =
            output.map((json) => Task.create(json)).toList();
        // save task (id registered, stored in db)
        for (final task in tasks) {
          ref.read(taskProvider.notifier).createTask(task);
        }
      } else {
        // generate update
        final output = await ref
            .read(aiServiceProvider)
            .updateTask(inputText, ref.read(selectedTaskProvider).toString());
        // update task
        ref.read(selectedTaskProvider)!.update(output[0]); // to fix later.
        // save update
        ref
            .read(taskProvider.notifier)
            .updateTask(ref.read(selectedTaskProvider)!);
        // unselect
        ref.read(selectedTaskProvider.notifier).state = null;
      }
      controller.clear();
      isInputEmpty.value = true;
      isLoading.value = false;
    }

    useEffect(() {
      void listener() {
        isFocused.value = focusNode.hasFocus;
      }

      focusNode.addListener(listener);
      return () => focusNode.removeListener(listener);
    }, [focusNode]);

    useEffect(() {
      if (ref.read(selectedTaskProvider) == null) {
        inputAction.value = "create";
      } else {
        inputAction.value = "update";
      }
      return null;
    }, [ref.watch(selectedTaskProvider)]);

    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.transparent, width: 0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedPadding(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: 22,
              right: 22,
              top: 12,
              bottom: isFocused.value ? 12 : 24,
            ),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: height * 0.3),
                  child: IntrinsicHeight(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textAlignVertical: TextAlignVertical.top,
                      maxLines: null,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText:
                            (inputAction.value == 'create')
                                ? 'Type something to remember.'
                                : 'Make a quick change.',
                        hintStyle: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      onChanged:
                          (text) => isInputEmpty.value = text.trim().isEmpty,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed:
                          (!isInputEmpty.value && !isLoading.value)
                              ? () {
                                handleSubmit();
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(10),
                        minimumSize: Size(36, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor:
                            (isInputEmpty.value)
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        elevation: 2,
                      ),
                      child: _buildSubmitIcon(
                        context,
                        inputAction: inputAction.value,
                        isLoading: isLoading.value,
                        isInputEmpty: isInputEmpty.value,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSubmitIcon(
  BuildContext context, {
  required String inputAction,
  required bool isLoading,
  required bool isInputEmpty,
}) {
  if (isLoading) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white, // Will be overridden by theme
        ),
      ),
    );
  } else if (inputAction == "update") {
    return Icon(
      Symbols.edit,
      color:
          isInputEmpty
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Theme.of(context).colorScheme.onPrimary,
      size: 20.0,
      weight: 800,
    );
  } else {
    // } else if (inputAction == "create") {
    return Icon(
      Symbols.add,
      color:
          isInputEmpty
              ? Theme.of(context).colorScheme.onSurfaceVariant
              : Theme.of(context).colorScheme.onPrimary,
      size: 20.0,
      weight: 800,
    );
  }
}
