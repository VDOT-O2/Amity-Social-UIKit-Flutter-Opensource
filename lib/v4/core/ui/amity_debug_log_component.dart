import 'package:amity_uikit_beta_service/v4/core/shared/debug/amity_debug_log_entry.dart';
import 'package:amity_uikit_beta_service/v4/core/styles.dart';
import 'package:amity_uikit_beta_service/v4/core/theme.dart';
import 'package:flutter/material.dart';

class AmityDebugLogComponent extends StatelessWidget {
  const AmityDebugLogComponent({
    super.key,
    required this.theme,
    this.title = 'Debug Logs',
    this.previewCount = 3,
    this.initialLogs = const <AmityDebugLogEntry>[],
    this.logStream,
    this.onClearHistory,
  });

  final AmityThemeColor theme;
  final String title;
  final int previewCount;
  final List<AmityDebugLogEntry> initialLogs;
  final Stream<List<AmityDebugLogEntry>>? logStream;
  final VoidCallback? onClearHistory;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AmityDebugLogEntry>>(
      stream: logStream,
      initialData: initialLogs,
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const <AmityDebugLogEntry>[];
        if (logs.isEmpty) {
          return const SizedBox.shrink();
        }

        final preview = logs.reversed.take(previewCount).toList();

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showFullHistory(context, logs),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.backgroundColor.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.baseColorShade3.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$title (${logs.length})',
                    style: AmityTextStyle.captionBold(theme.baseColor),
                  ),
                  const SizedBox(height: 6),
                  ...preview.map((entry) => _buildPreviewRow(entry)).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewRow(AmityDebugLogEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '${_formatTime(entry.timestamp)}  [${entry.level.name.toUpperCase()}] ${entry.action}: ${entry.message}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AmityTextStyle.caption(theme.baseColorShade1),
      ),
    );
  }

  void _showFullHistory(BuildContext context, List<AmityDebugLogEntry> logs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        final mediaQuery = MediaQuery.of(sheetContext);

        return StreamBuilder<List<AmityDebugLogEntry>>(
          stream: logStream,
          initialData: logs,
          builder: (context, snapshot) {
            final currentLogs = snapshot.data ?? const <AmityDebugLogEntry>[];
            final orderedLogs = currentLogs.reversed.toList();

            return SizedBox(
              height: mediaQuery.size.height * 0.75,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 36,
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 4,
                          decoration: ShapeDecoration(
                            color: theme.baseColorShade3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$title (${orderedLogs.length})',
                            style: AmityTextStyle.titleBold(theme.baseColor),
                          ),
                        ),
                        if (onClearHistory != null && orderedLogs.isNotEmpty)
                          TextButton(
                            onPressed: onClearHistory,
                            child: Text(
                              'Clear',
                              style: AmityTextStyle.bodyBold(theme.alertColor),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: orderedLogs.isEmpty
                        ? Center(
                            child: Text(
                              'No logs yet',
                              style: AmityTextStyle.body(theme.baseColorShade1),
                            ),
                          )
                        : ListView.separated(
                            itemCount: orderedLogs.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: theme.baseColorShade4,
                            ),
                            itemBuilder: (context, index) {
                              final log = orderedLogs[index];
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                title: Text(
                                  '${_formatTime(log.timestamp)}  ${_formatActionLabel(log)}',
                                  style: AmityTextStyle.caption(theme.baseColorShade1),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '[${log.level.name.toUpperCase()}] ${log.message}',
                                    style: AmityTextStyle.body(theme.baseColor),
                                  ),
                                ),
                                onTap: log.snapshot == null
                                    ? null
                                    : () => _showSnapshotDialog(context, log),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSnapshotDialog(BuildContext context, AmityDebugLogEntry log) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _formatActionLabel(log),
            style: AmityTextStyle.titleBold(theme.baseColor),
          ),
          content: SingleChildScrollView(
            child: SelectableText(
              log.snapshot ?? '',
              style: AmityTextStyle.caption(theme.baseColor),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Close',
                style: AmityTextStyle.bodyBold(theme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    final ms = time.millisecond.toString().padLeft(3, '0');
    return '$hh:$mm:$ss.$ms';
  }

  String _formatActionLabel(AmityDebugLogEntry log) {
    final normalizedScope = log.scope.trim();
    if (normalizedScope.isEmpty) {
      return log.action;
    }
    return '$normalizedScope.${log.action}';
  }
}
