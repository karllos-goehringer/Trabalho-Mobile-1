import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/NotaClass.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _titleController = TextEditingController();
  final QuillController _quillController = QuillController.basic();
  Uint8List? imageBytes;

  final String _selectedDate = DateFormat(
    'dd/MM/yyyy HH:mm',
  ).format(DateTime.now());

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    final bytes = await image.readAsBytes();

    setState(() {
      imageBytes = bytes;
    });
  }

  void removeImage() {
    setState(() {
      imageBytes = null;
    });
  }

void saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha o título!")));
      return;
    }

    final richTextJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    if (_quillController.document.toPlainText().trim().isEmpty &&
        imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("A nota não pode estar vazia!")),
      );
      return;
    }

    final nota = Nota(
      id: DateTime.now().millisecondsSinceEpoch.hashCode,
      titulo: _titleController.text,
      texto: richTextJson,
      momentoCadastro: _selectedDate,
      imageBytes: imageBytes,
    );

    final notaBox = Hive.box<Nota>('notaBox');
    await notaBox.add(nota);

    Navigator.pop(context, nota);
  }

  @override
  Widget build(BuildContext context) {
    const double editorHeight = 300;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    final editorBackgroundColor = colorScheme.surface;
    final toolbarBackgroundColor = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainer;
    final borderColor = colorScheme.outlineVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Anotação"),
        actions: [
          IconButton(onPressed: saveNote, icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Título",
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: toolbarBackgroundColor,
                    border: Border.all(color: borderColor),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: QuillSimpleToolbar(
                    controller: _quillController,
                    config: const QuillSimpleToolbarConfig(
                      showAlignmentButtons: false,
                      showSearchButton: false,
                      multiRowsDisplay: true,
                    ),
                  ),
                ),

                Container(
                  height: editorHeight,
                  decoration: BoxDecoration(
                    color: editorBackgroundColor,
                    border: Border.all(color: borderColor),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: QuillEditor(
                    controller: _quillController,
                    config: QuillEditorConfig(
                      checkBoxReadOnly: false,
                      padding: const EdgeInsets.all(12),
                      placeholder:
                          'Digite o conteúdo da nota com formatação aqui...',
                    ),
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                TextButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Adicionar imagem"),
                ),
                if (imageBytes != null)
                  TextButton.icon(
                    onPressed: removeImage,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text("Remover imagem"),
                  ),
              ],
            ),

            if (imageBytes != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    imageBytes!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
