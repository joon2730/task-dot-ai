import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:tasket/model/task.dart';
import 'package:tasket/provider/task_provider.dart';
import 'package:tasket/provider/service_provider.dart';
import 'package:tasket/provider/focus_node_provider.dart';
import 'package:tasket/util/exception.dart';

class InputBox extends HookConsumerWidget {
  const InputBox({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final focusNode = ref.watch(inputBoxFocusNodeProvider);
    final height = MediaQuery.of(context).size.height;
    final isInputEmpty = useState(true);
    final isLoading = useState(false);
    final isFocused = useState(false);
    final inputAction = useState("create");

    Future<void> handleSubmit() async {
      final inputText = controller.text;
      FocusScope.of(context).unfocus();
      isLoading.value = true;
      try {
        if (ref.read(selectedTaskProvider) == null) {
          // generate new task
          final output = await ref
              .read(aiServiceProvider)!
              .createTasks(inputText);
          // create and save task
          ref.read(taskProvider.notifier).createTask(Task.create(output));
        } else {
          // generate update
          final output = await ref
              .read(aiServiceProvider)!
              .updateTask(inputText, ref.read(selectedTaskProvider).toString());
          // update task
          ref.read(selectedTaskProvider)!.update(output);
          // save update
          ref
              .read(taskProvider.notifier)
              .updateTask(ref.read(selectedTaskProvider)!);
        }
      } catch (e, _) {
        if (context.mounted) {
          handleException(context, e);
        }
      }
      // unselect
      ref.read(selectedTaskProvider.notifier).state = null;
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
    }, []);

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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isInputEmpty.value) ...[
                      TextButton(
                        onPressed:
                            isInputEmpty.value
                                ? null
                                : () {
                                  controller.clear();
                                  isInputEmpty.value = true;
                                },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(36, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Clear',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                    ],
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
                                : (inputAction.value == 'create')
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
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
