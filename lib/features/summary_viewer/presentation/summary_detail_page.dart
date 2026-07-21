import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/summary_record.dart';
import '../../../services/providers.dart';
import '../../home/providers/home_providers.dart';

/// Minimal summary detail view backing Phase 5's "tap-through to summary
/// view" requirement. Deliberately plain (no Markdown rendering, no TTS bar
/// yet) - Phase 7 replaces the body with the full Markdown + TTS experience.
class SummaryDetailPage extends ConsumerWidget {
  const SummaryDetailPage({super.key, required this.summaryId});

  final int summaryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(summariesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
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

    return ListView(
      padding: const EdgeInsets.all(16),
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
        Text(record.executiveSummary),
        if (sections.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Sections', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final section in sections) _SectionTile(section: section),
        ],
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
          Text(section.summaryText ?? ''),
          for (final point in keyPoints)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('- $point'),
            ),
        ],
      ),
    );
  }
}
