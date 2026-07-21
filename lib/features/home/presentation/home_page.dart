import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/summary_record.dart';
import '../../../services/providers.dart';
import '../../summary_viewer/presentation/summary_detail_page.dart';
import '../../upload/presentation/upload_page.dart';
import '../providers/home_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(summariesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('SummaRead')),
      body: summariesAsync.when(
        data: (summaries) => summaries.isEmpty
            ? const _EmptyState()
            : _SummaryList(summaries: summaries),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Something went wrong: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New summary',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const UploadPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.summarize_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('No summaries yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to summarize a PDF, Word document, spreadsheet, or web article.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryList extends StatelessWidget {
  const _SummaryList({required this.summaries});

  final List<SummaryRecord> summaries;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: summaries.length,
      itemBuilder: (context, index) => _SummaryCard(record: summaries[index]),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.record});

  final SummaryRecord record;

  IconData _iconForDocType(DocumentType docType) {
    switch (docType) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf_outlined;
      case DocumentType.docx:
        return Icons.description_outlined;
      case DocumentType.excel:
        return Icons.table_chart_outlined;
      case DocumentType.webArticle:
        return Icons.public;
    }
  }

  Future<void> _toggleFavorite(WidgetRef ref) async {
    final isarService = await ref.read(isarServiceProvider.future);
    await isarService.toggleFavorite(record.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(_iconForDocType(record.docType)),
      title: Text(record.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${record.estimatedReadTimeMinutes} min read'),
      trailing: IconButton(
        icon: Icon(record.isFavorite ? Icons.star : Icons.star_border),
        tooltip: record.isFavorite
            ? 'Remove from favorites'
            : 'Add to favorites',
        onPressed: () => _toggleFavorite(ref),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SummaryDetailPage(summaryId: record.id),
        ),
      ),
    );
  }
}
