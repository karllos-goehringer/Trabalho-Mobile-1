import 'dart:io';
import 'dart:convert'; // Import necessário para jsonEncode()
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Import do Quill
import '../models/NotaClass.dart'; // Modelo Nota
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/widgets.dart';

class CreateNotePage extends StatefulWidget {
  const CreateNotePage({super.key});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _titleController = TextEditingController();
  // Inicialização do QuillController para gerenciar o conteúdo rico
  final QuillController _quillController = QuillController.basic();

  Uint8List? imageBytes;

  final String _selectedDate = DateFormat(
    'dd/MM/yyyy HH:mm',
  ).format(DateTime.now());

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose(); // Não esqueça de descartar o QuillController
    super.dispose();
  }

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
    // 1. Verifica se o título está vazio
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha o título!")));
      return;
    }

    // 2. Serializa o conteúdo do Quill para uma string JSON (Delta)
    final richTextJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    // 3. Verifica se o texto rico está vazio (usando texto simples para validação)
    if (_quillController.document.toPlainText().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O texto da nota não pode estar vazio!")),
      );
      return;
    }

    final nota = Nota(
      titulo: _titleController.text,
      texto: richTextJson, // Salva o JSON serializado
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
    const double editorHeight = 300; // Altura fixa para o editor no ListView
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    // Define as cores dinâmicas
    final editorBackgroundColor = colorScheme.surface;
    // Usa uma cor ligeiramente diferente da superfície para dar destaque à barra de ferramentas
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
            // Campo Título (TextField)
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Título"),
              style: TextStyle(
                color: colorScheme.onSurface,
              ), // Adapta a cor do texto
            ),
            const SizedBox(height: 20),

            // O editor de texto rico com sua barra de ferramentas
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de ferramentas do Quill
                Container(
                  decoration: BoxDecoration(
                    color: toolbarBackgroundColor, // COR DINÂMICA
                    border: Border.all(color: borderColor), // COR DINÂMICA
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: QuillSimpleToolbar(
                    controller: _quillController,
                    // Os ícones dos botões se adaptam automaticamente ao tema
                    config: const QuillSimpleToolbarConfig(
                      showAlignmentButtons: false,
                      showSearchButton: false,
                      showColorButton: true,
                      showBackgroundColorButton: true,
                      multiRowsDisplay: true,
                    ),
                  ),
                ),

                // Editor de texto (substituindo o TextField anterior)
                Container(
                  height: editorHeight, // Altura fixa
                
                  decoration: BoxDecoration(
                    color: editorBackgroundColor,
                    border: Border.all(color: borderColor), // COR DINÂMICA
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
                      // É importante definir o estilo padrão do texto para garantir que ele seja legível em ambos os temas.
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          TextStyle(color: colorScheme.onSurface),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0,0,), // lineSpacing obrigatório
                          null, // decoration pode ser null
                        ),
                      ),
                    ),
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Botão Adicionar Imagem (mantido)
            TextButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Adicionar imagem"),
            ),

            // Pré-visualização da imagem (mantida)
            if (imageBytes != null)
              Column(
                children: [
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      imageBytes!,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
