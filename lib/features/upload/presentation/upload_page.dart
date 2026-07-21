import 'package:flutter/material.dart';

/// Placeholder for the real Upload screen (file picker + URL dialog) built in
/// Phase 6. Exists now so Phase 5's Home dashboard has somewhere to navigate
/// its "new summary" action to.
class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Summary')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'File picking and URL upload are coming in Phase 6.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
