import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/user_facing_error.dart';
import '../../../models/summary_record.dart';
import '../../../services/providers.dart';
import '../../settings/presentation/settings_page.dart';
import '../../summary_viewer/presentation/summary_detail_page.dart';
import '../logic/summary_pipeline_provider.dart';
import '../logic/upload_source.dart';

/// Extensions the file picker is restricted to - kept as a named constant so
/// it can be asserted on directly in tests without driving the native picker.
const List<String> kAllowedUploadExtensions = ['pdf', 'docx', 'xlsx'];

/// Files larger than this are rejected before extraction even starts, so a
/// huge pick doesn't get read entirely into memory (extractors load the
/// whole file's bytes) on a phone. 50MB comfortably covers real-world
/// PDFs/DOCX/XLSX while ruling out pathological picks.
const int kMaxUploadFileBytes = 50 * 1024 * 1024;

String _formatMegabytes(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  bool _navigated = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: kAllowedUploadExtensions,
      withData: true,
    );
    if (result == null || !mounted) return;

    final file = result.files.single;
    if (file.size > kMaxUploadFileBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'That file is ${_formatMegabytes(file.size)}, over the '
            '${_formatMegabytes(kMaxUploadFileBytes)} limit. Try a smaller file.',
          ),
        ),
      );
      return;
    }

    final path = await _resolveFilePath(file);
    if (path == null || !mounted) return;
    await ref.read(summaryPipelineControllerProvider.notifier).run(FileUploadSource(path));
  }

  /// Some Android content providers (Downloads, Drive, etc. - common on
  /// emulators) don't expose a real filesystem path for the picked file, only
  /// raw bytes. In that case, write the bytes to a temp file so the rest of
  /// the pipeline (which extracts by path) can proceed unchanged. Without
  /// this fallback, picking such a file silently did nothing.
  Future<String?> _resolveFilePath(PlatformFile file) async {
    if (file.path != null) return file.path;

    final bytes = file.bytes;
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read the selected file. Please try again.')),
      );
      return null;
    }

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/${file.name}');
    await tempFile.writeAsBytes(bytes);
    return tempFile.path;
  }

  Future<void> _pasteUrl() async {
    final url = await showDialog<String>(
      context: context,
      builder: (context) => const _UrlInputDialog(),
    );
    if (url == null || !mounted) return;
    await ref.read(summaryPipelineControllerProvider.notifier).run(UrlUploadSource(url));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<AsyncValue<SummaryRecord?>>(summaryPipelineControllerProvider, (
      previous,
      next,
    ) {
      final record = next.value;
      if (!_navigated && record != null) {
        _navigated = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SummaryDetailPage(summaryId: record.id)),
        );
        return;
      }
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingErrorMessage(next.error!))),
        );
      }
    });

    final isLoading = ref.watch(
      summaryPipelineControllerProvider.select((state) => state.isLoading),
    );
    final hasApiKey = ref.watch(apiKeyControllerProvider).valueOrNull != null;

    return Scaffold(
      appBar: AppBar(title: const Text('New Summary')),
      body: Center(
        child: isLoading
            ? const _LoadingState()
            : !hasApiKey
            ? const _NoApiKeyState()
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.upload_file_outlined,
                      size: 64,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Summarize a document or web article',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Choose a file (PDF, DOCX, XLSX)'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pasteUrl,
                      icon: const Icon(Icons.link),
                      label: const Text('Paste a web article URL'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Shown instead of the upload actions until the user saves a Gemini API key
/// in Settings (spec: "the app has no working AI feature until a key is
/// entered").
class _NoApiKeyState extends StatelessWidget {
  const _NoApiKeyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.vpn_key_off_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'Add your Gemini API key to get started',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'SummaRead needs a Gemini API key to summarize documents and articles.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text('Summarizing...', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _UrlInputDialog extends StatefulWidget {
  const _UrlInputDialog();

  @override
  State<_UrlInputDialog> createState() => _UrlInputDialogState();
}

class _UrlInputDialogState extends State<_UrlInputDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A URL is accepted only if it parses and has an http/https scheme and a
  /// non-empty host - rejects things like empty input, plain text, or
  /// `ftp://...`/`file://...` links this pipeline can't fetch as a web article.
  static bool isValidArticleUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    return uri.host.isNotEmpty;
  }

  void _submit() {
    final value = _controller.text.trim();
    if (!isValidArticleUrl(value)) {
      setState(() => _errorText = 'Enter a valid http(s) URL');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Paste a web article URL'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          hintText: 'https://example.com/article',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Summarize')),
      ],
    );
  }
}
