import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/summary_record.dart';
import '../../../services/providers.dart';

/// Newest-first list of saved summaries, live-updating as records are added,
/// favorited, or removed.
final summariesStreamProvider = StreamProvider<List<SummaryRecord>>((ref) async* {
  final isarService = await ref.watch(isarServiceProvider.future);
  yield* isarService.watchAllSummaries();
});
