import 'package:flutter/material.dart';

final GlobalKey _menuKey = GlobalKey();

class TopBar extends StatelessWidget {
  final bool innerBoxIsScrolled;

  const TopBar({super.key, required this.innerBoxIsScrolled});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      forceElevated: innerBoxIsScrolled,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.menu,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {},
              ),
              TextButton(
                key: _menuKey,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder:
                        (context) => Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 80.0,
                            ), // adjust Y position
                            child: Material(
                              borderRadius: BorderRadius.circular(16),
                              elevation: 8,
                              color: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildPopoverItem(
                                    context,
                                    Icons.model_training,
                                    '모델',
                                    trailing: Icons.chevron_right,
                                  ),
                                  _buildPopoverItem(context, Icons.share, '공유'),
                                  _buildPopoverItem(
                                    context,
                                    Icons.edit,
                                    '이름 바꾸기',
                                  ),
                                  _buildPopoverItem(
                                    context,
                                    Icons.info_outline,
                                    '세부 정보 보기',
                                  ),
                                  _buildPopoverItem(
                                    context,
                                    Icons.archive_outlined,
                                    '아카이브에 보관',
                                  ),
                                  const Divider(height: 1),
                                  _buildPopoverItem(
                                    context,
                                    Icons.delete,
                                    '삭제',
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      "All Tasks",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.tune,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopoverItem(
    BuildContext context,
    IconData icon,
    String label, {
    IconData? trailing,
    Color? color,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: color),
      title: Text(label, style: TextStyle(fontSize: 14, color: color)),
      trailing: trailing != null ? Icon(trailing, size: 16) : null,
      onTap: () => Navigator.pop(context),
    );
  }
}
