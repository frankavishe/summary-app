import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_preview.dart';
import '../../../models/summary_record.dart';
import '../../../services/providers.dart';
import '../../settings/presentation/settings_page.dart';
import '../../summary_viewer/presentation/summary_detail_page.dart';
import '../../upload/presentation/upload_page.dart';
import '../providers/home_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchController = TextEditingController();
  DocumentType? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SummaryRecord> _visible(List<SummaryRecord> all) {
    final query = _searchController.text.trim().toLowerCase();
    return all.where((record) {
      final matchesType =
          _selectedType == null || record.docType == _selectedType;
      final matchesQuery =
          query.isEmpty || record.title.toLowerCase().contains(query);
      return matchesType && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final summariesAsync = ref.watch(summariesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            const Text('SummaRead'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: summariesAsync.when(
        data: (summaries) => summaries.isEmpty
            ? const _EmptyState()
            : _Dashboard(
                allSummaries: summaries,
                visibleSummaries: _visible(summaries),
                searchController: _searchController,
                selectedType: _selectedType,
                onSearchChanged: () => setState(() {}),
                onTypeSelected: (type) => setState(() => _selectedType = type),
              ),
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
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.summarize_outlined,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('No summaries yet', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to summarize a PDF, Word document, spreadsheet, or web article.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The main dashboard body once at least one summary exists: greeting +
/// search + doc-type filter chips + the (search/filter-narrowed) card list,
/// ending in a "start a new summary" action card.
class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.allSummaries,
    required this.visibleSummaries,
    required this.searchController,
    required this.selectedType,
    required this.onSearchChanged,
    required this.onTypeSelected,
  });

  final List<SummaryRecord> allSummaries;
  final List<SummaryRecord> visibleSummaries;
  final TextEditingController searchController;
  final DocumentType? selectedType;
  final VoidCallback onSearchChanged;
  final ValueChanged<DocumentType?> onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFiltered =
        searchController.text.trim().isNotEmpty || selectedType != null;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Reader',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  allSummaries.length == 1
                      ? 'You have 1 summary saved.'
                      : 'You have ${allSummaries.length} summaries saved.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: searchController,
                  onChanged: (_) => onSearchChanged(),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search saved summaries...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Clear search',
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged();
                            },
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All Files',
                        selected: selectedType == null,
                        onTap: () => onTypeSelected(null),
                      ),
                      for (final type in DocumentType.values) ...[
                        const SizedBox(width: 10),
                        _FilterChip(
                          label: _styleFor(type).label,
                          selected: selectedType == type,
                          onTap: () => onTypeSelected(type),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        if (visibleSummaries.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _NoMatchesState(isFiltered: isFiltered),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList.separated(
              itemCount: visibleSummaries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) =>
                  _SummaryCard(record: visibleSummaries[index]),
            ),
          ),
      ],
    );
  }
}

class _NoMatchesState extends StatelessWidget {
  const _NoMatchesState({required this.isFiltered});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              isFiltered ? 'No summaries match' : 'No summaries yet',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHigh;
    final foreground = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;
    return Material(
      color: background,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon + short label shown for a [DocumentType] on its card's avatar and
/// filter-tag chip.
class _DocTypeStyle {
  const _DocTypeStyle({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

_DocTypeStyle _styleFor(DocumentType docType) {
  switch (docType) {
    case DocumentType.pdf:
      return const _DocTypeStyle(
        icon: Icons.picture_as_pdf_outlined,
        label: 'PDF',
      );
    case DocumentType.docx:
      return const _DocTypeStyle(
        icon: Icons.description_outlined,
        label: 'DOCX',
      );
    case DocumentType.excel:
      return const _DocTypeStyle(
        icon: Icons.table_chart_outlined,
        label: 'Excel',
      );
    case DocumentType.webArticle:
      return const _DocTypeStyle(icon: Icons.public, label: 'Web Article');
  }
}

/// Alternates the icon-avatar tint between the primary and tertiary "fixed"
/// containers so consecutive cards in the list read as visually distinct,
/// while the icon glyph itself always stays primary-colored (matches
/// `design/code.html`'s card avatars).
bool _usesTertiaryTint(DocumentType docType) {
  switch (docType) {
    case DocumentType.pdf:
    case DocumentType.excel:
      return false;
    case DocumentType.docx:
    case DocumentType.webArticle:
      return true;
  }
}

/// Shows a confirmation dialog before deleting [title], returning whether the
/// user confirmed - shared by the home list's swipe-to-delete and the detail
/// page's delete action so both ask the same question.
Future<bool> confirmDeleteSummary(BuildContext context, String title) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete summary?'),
      content: Text('"$title" will be permanently deleted.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.record});

  final SummaryRecord record;

  Future<void> _toggleFavorite(WidgetRef ref) async {
    final isarService = await ref.read(isarServiceProvider.future);
    await isarService.toggleFavorite(record.id);
  }

  Future<void> _delete(WidgetRef ref) async {
    final isarService = await ref.read(isarServiceProvider.future);
    await isarService.deleteSummary(record.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style = _styleFor(record.docType);
    final avatarColor = _usesTertiaryTint(record.docType)
        ? theme.colorScheme.tertiaryFixed
        : theme.colorScheme.primaryFixed;
    final preview = previewText(record.executiveSummary);

    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDeleteSummary(context, record.title),
      onDismissed: (_) => _delete(ref),
      background: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SummaryDetailPage(summaryId: record.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: avatarColor,
                        borderRadius: BorderRadius.circular(
                          AppTheme.controlRadius + 4,
                        ),
                      ),
                      child: Icon(style.icon, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        record.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        record.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: record.isFavorite
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline,
                      ),
                      tooltip: record.isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      onPressed: () => _toggleFavorite(ref),
                    ),
                  ],
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Divider(color: theme.colorScheme.outlineVariant, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(
                          AppTheme.controlRadius,
                        ),
                      ),
                      child: Text(
                        style.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${record.estimatedReadTimeMinutes} min read',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
