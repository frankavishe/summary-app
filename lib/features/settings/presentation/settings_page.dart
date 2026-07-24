import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/providers.dart';

/// Lets the user paste, save, and clear their own Gemini API key. The key is
/// never bundled with the app (spec section 8) and is stored only in secure
/// on-device storage via [apiKeyControllerProvider].
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    await ref.read(apiKeyControllerProvider.notifier).save(value);
    _controller.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key saved')));
  }

  Future<void> _clear() async {
    await ref.read(apiKeyControllerProvider.notifier).clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key cleared')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final apiKeyAsync = ref.watch(apiKeyControllerProvider);
    final hasKey = apiKeyAsync.valueOrNull != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Gemini API Key', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                hasKey ? Icons.check_circle : Icons.error_outline,
                color: hasKey ? Colors.green : theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(hasKey ? 'An API key is configured' : 'No API key configured'),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Paste your Gemini API key',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                tooltip: _obscure ? 'Show key' : 'Hide key',
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final hasInput = value.text.trim().isNotEmpty;
              return Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: hasInput ? _save : null,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: hasKey ? _clear : null,
                      child: const Text('Clear'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            "Your key is stored securely on this device and is sent only to Google's Gemini API "
            'when generating a summary.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
