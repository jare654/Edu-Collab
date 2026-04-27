import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/theme/app_theme.dart';

class NoteEditorScreen extends StatefulWidget {
  final bool isNew;
  const NoteEditorScreen({super.key, this.isNew = true});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.isNew ? '' : 'Sustainable Architecture Concepts');
    _bodyController = TextEditingController(text: widget.isNew ? '' : 'Key principles: \n1. Energy efficiency \n2. Sustainable materials\n3. Integration with local environment.');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved successfully.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens_outlined, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.primary),
            onPressed: _saveNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Note Title',
                hintStyle: TextStyle(color: AppTheme.textTertiary),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 16, height: 1.5, color: AppTheme.textSecondary),
                decoration: const InputDecoration(
                  hintText: 'Start typing your notes here...',
                  hintStyle: TextStyle(color: AppTheme.textTertiary),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
