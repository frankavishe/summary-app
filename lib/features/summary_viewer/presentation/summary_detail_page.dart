import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/summary_record.dart';
import '../../../services/providers.dart';
import '../../../services/tts_service.dart';
import '../../home/presentation/home_page.dart' show confirmDeleteSummary;
import '../../home/providers/home_providers.dart';

/// Full summary breakdown - executive summary + section/sheet-by-sheet
/// detail rendered as Markdown - with a play/pause/stop bar that reads the
/// summary aloud via [TtsService].
class SummaryDetailPage extends ConsumerWidget {
  const SummaryDetailPage({super.key, required this.summaryId});

  final int summaryId;

  Future<void> _delete(BuildContext context, WidgetRef ref, SummaryRecord record) async {
    final confirmed = await confirmDeleteSummary(context, record.title);
    if (!confirmed) return;
    final isarService = await ref.read(isarServiceProvider.future);
    await isarService.deleteSummary(record.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(summariesStreamProvider);
    final record = summariesAsync.valueOrNull?.where((s) => s.id == summaryId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        actions: [
          if (record != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete summary',
              onPressed: () => _delete(context, ref, record),
            ),
        ],
      ),
      body: summariesAsync.when(
        data: (summaries) {
          final record = summaries.where((s) => s.id == summaryId).firstOrNull;
          if (record == null) {
            return const Center(child: Text('This summary no longer exists.'));
          }
          return _SummaryDetailBody(record: record);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Something went wrong: $error')),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Builds the plain-text script read aloud by TTS: the executive summary
/// followed by each section's title and body, with Markdown syntax stripped
/// since it would otherwise be read out literally (e.g. "asterisk asterisk").
String _speechTextFor(SummaryRecord record) {
  final buffer = StringBuffer(_stripMarkdown(record.executiveSummary));
  for (final section in record.sections ?? const <SectionSummary>[]) {
    final title = section.sectionTitle;
    if (title != null && title.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(title);
    }
    final body = section.summaryText;
    if (body != null && body.isNotEmpty) {
      buffer.writeln(_stripMarkdown(body));
    }
    for (final point in section.keyPoints ?? const <String>[]) {
      buffer.writeln(_stripMarkdown(point));
    }
  }
  return buffer.toString().trim();
}

String _stripMarkdown(String text) {
  return text.replaceAll(RegExp(r'[*_#`>-]'), '').trim();
}

class _SummaryDetailBody extends ConsumerWidget {
  const _SummaryDetailBody({required this.record});

  final SummaryRecord record;

  Future<void> _toggleFavorite(WidgetRef ref) async {
    final isarService = await ref.read(isarServiceProvider.future);
    await isarService.toggleFavorite(record.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sections = record.sections ?? const [];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(record.title, style: theme.textTheme.headlineSmall),
                  ),
                  IconButton(
                    icon: Icon(record.isFavorite ? Icons.star : Icons.star_border),
                    tooltip: record.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    onPressed: () => _toggleFavorite(ref),
                  ),
                ],
              ),
              Text(
                '${record.estimatedReadTimeMinutes} min read',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text('Executive Summary', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              MarkdownBody(data: record.executiveSummary),
              if (sections.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Sections', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final section in sections) _SectionTile(section: section),
              ],
            ],
          ),
        ),
        _TtsControlBar(record: record),
      ],
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section});

  final SectionSummary section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyPoints = section.keyPoints ?? const [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.sectionTitle ?? '', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          MarkdownBody(data: section.summaryText ?? ''),
          for (final point in keyPoints)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: MarkdownBody(data: '- $point'),
            ),
        ],
      ),
    );
  }
}

/// Play/pause/stop bar that reads [record]'s executive summary and sections
/// aloud through the shared [ttsServiceProvider].
class _TtsControlBar extends ConsumerWidget {
  const _TtsControlBar({required this.record});

  final SummaryRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ttsService = ref.watch(ttsServiceProvider);
    final playbackState = ref
        .watch(ttsStateProvider)
        .maybeWhen(data: (state) => state, orElse: () => TtsPlaybackState.stopped);

    Future<void> togglePlayPause() async {
      switch (playbackState) {
        case TtsPlaybackState.stopped:
          await ttsService.speak(_speechTextFor(record));
          break;
        case TtsPlaybackState.playing:
          await ttsService.pause();
          break;
        case TtsPlaybackState.paused:
          await ttsService.resume();
          break;
      }
    }

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                iconSize: 36,
                icon: Icon(
                  playbackState == TtsPlaybackState.playing ? Icons.pause_circle : Icons.play_circle,
                ),
                tooltip: playbackState == TtsPlaybackState.playing ? 'Pause' : 'Play',
                onPressed: togglePlayPause,
              ),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.stop_circle_outlined),
                tooltip: 'Stop',
                onPressed: playbackState == TtsPlaybackState.stopped ? null : () => ttsService.stop(),
              ),
              Expanded(
                child: Text(
                  switch (playbackState) {
                    TtsPlaybackState.stopped => 'Listen to this summary',
                    TtsPlaybackState.playing => 'Reading summary...',
                    TtsPlaybackState.paused => 'Paused',
                  },
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
