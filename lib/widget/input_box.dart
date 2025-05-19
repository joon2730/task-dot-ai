import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:tasket/util/prompt.dart';
// import 'package:tasket/model/task_patch.dart';
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

    Future<void> handleSubmit() async {
      final inputText = controller.text;
      FocusScope.of(context).unfocus();
      isLoading.value = true;
      print(taskUserPrompt(inputText, ref.read(taskProvider).value ?? []));
      final patches = await ref
          .read(aiServiceProvider)
          .generateTaskPatches(
            taskUserPrompt(inputText, ref.read(taskProvider).value ?? []),
          );
      await ref.read(taskProvider.notifier).applyTaskPatches(patches);
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
      child: AnimatedPadding(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 16,
          bottom: isFocused.value ? 16 : 32,
        ),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height * 0.4),
              child: IntrinsicHeight(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: null,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Write anything to remember',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  onChanged: (text) => isInputEmpty.value = text.trim().isEmpty,
                ),
              ),
            ),
            SizedBox(height: 8),
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
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 2,
                  ),
                  child:
                      isLoading.value
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                          : Icon(
                            Icons.keyboard_return,
                            color:
                                (isInputEmpty.value || isLoading.value)
                                    ? Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant
                                    : Theme.of(context).colorScheme.onPrimary,
                            size: 20,
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
