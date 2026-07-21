import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/summary_record.dart';
import '../../../services/providers.dart';
import 'summary_pipeline.dart';
import 'upload_source.dart';

/// Drives the extract -> summarize -> save pipeline for a single upload and
/// exposes its loading/data/error state to the UI (a real Upload screen in
/// Phase 6; a headless trigger in tests today).
class SummaryPipelineController extends AsyncNotifier<SummaryRecord?> {
  @override
  Future<SummaryRecord?> build() async => null;

  Future<void> run(UploadSource source) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final isarService = await ref.read(isarServiceProvider.future);
      final aiService = ref.read(aiServiceProvider);
      final pipeline = SummaryPipeline(isarService: isarService, aiService: aiService);
      return pipeline.run(source);
    });
  }
}

final summaryPipelineControllerProvider =
    AsyncNotifierProvider<SummaryPipelineController, SummaryRecord?>(
  SummaryPipelineController.new,
);
