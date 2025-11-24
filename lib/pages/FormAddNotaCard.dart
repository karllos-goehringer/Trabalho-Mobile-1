import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final _textController = TextEditingController();
  Uint8List? imageBytes;

  final String _selectedDate = DateFormat(
    'dd/MM/yyyy HH:mm',
  ).format(DateTime.now());

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final bytes = await image.readAsBytes(); // <- lê bytes

    setState(() {
      imageBytes = bytes; // <- armazena para salvar no Hive
    });
  }

  void saveNote() async {
    if (_titleController.text.isEmpty || _textController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha título e texto!")));
      return;
    }

    final nota = Nota(
      titulo: _titleController.text,
      texto: _textController.text,
      momentoCadastro: _selectedDate,
      imageBytes: imageBytes,
    );

    // --- SALVAR NO HIVE (nome correto: notaBox) ---
    final notaBox = Hive.box<Nota>('notaBox');
    await notaBox.add(nota);

    Navigator.pop(context, nota);
  }

  @override
  Widget build(BuildContext context) {
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
              decoration: const InputDecoration(labelText: "Título"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(labelText: "Texto"),
              maxLines: 6,
            ),
            const SizedBox(height: 20),

            TextButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Adicionar imagem"),
            ),
            if (imageBytes != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      imageBytes!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
