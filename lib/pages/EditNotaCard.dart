import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Para o editor
import '../models/NotaClass.dart'; // O modelo de dados Nota
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class EditNotePage extends StatefulWidget {
  final Nota nota;

  const EditNotePage({super.key, required this.nota});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  // O late é usado porque estes objetos serão inicializados no initState com os dados da nota
  late TextEditingController _titleController;
  late QuillController _quillController;
  
  Uint8List? imageBytes;
  
  @override
  void initState() {
    super.initState();
    
    // 1. Inicializa o título com o valor existente
    _titleController = TextEditingController(text: widget.nota.titulo);

    // 2. Inicializa o conteúdo rico com o valor existente
    try {
      final docJson = jsonDecode(widget.nota.texto);
      final document = Document.fromJson(docJson);
      _quillController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // Fallback: se o JSON estiver inválido, inicia com texto simples
      final document = Document()..insert(0, 'Erro ao carregar conteúdo de texto rico. Texto original: ${widget.nota.texto}');
      _quillController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    // 3. Inicializa a imagem existente
    imageBytes = widget.nota.imageBytes;
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha o título!")),
      );
      return;
    }
    
    final richTextJson = jsonEncode(_quillController.document.toDelta().toJson());

    if (_quillController.document.toPlainText().trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O texto da nota não pode estar vazio!")),
      );
      return;
    }

    // ATUALIZA o objeto Nota existente
    widget.nota.titulo = _titleController.text;
    widget.nota.texto = richTextJson; 
    widget.nota.imageBytes = imageBytes;
    
    // Salva as alterações no Hive

    final _momentoEdicao = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nota '${widget.nota.titulo}' atualizada em $_momentoEdicao")),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const double editorHeight = 300; 
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    // Define as cores dinâmicas
    final editorBackgroundColor = colorScheme.surface;
    final toolbarBackgroundColor = isDark 
        ? colorScheme.surfaceContainerHighest 
        : colorScheme.surfaceContainer; 
    final borderColor = colorScheme.outlineVariant;


    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Anotação"),
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
              style: TextStyle(color: colorScheme.onSurface), 
            ),
            // Informação da criação/edição
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
              child: Text(
                "Criado em: ${widget.nota.momentoCadastro}",
                style: TextStyle(
                  fontSize: 13, 
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // O editor de texto rico com sua barra de ferramentas
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra de ferramentas do Quill
                Container(
                  decoration: BoxDecoration(
                    color: toolbarBackgroundColor, 
                    border: Border.all(color: borderColor), 
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), 
                  ),
                  child: QuillSimpleToolbar(
                    controller: _quillController,
                    config: const QuillSimpleToolbarConfig(
                      showAlignmentButtons: false,
                      showSearchButton: false,
                      showColorButton: true,
                      showBackgroundColorButton: true,
                      multiRowsDisplay: true,
                    ),
                  ),
                ),
                
                // Editor de texto
                Container(
                  height: editorHeight, 
                  decoration: BoxDecoration(
                    color: editorBackgroundColor, 
                    border: Border.all(color: borderColor), 
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: QuillEditor(
                    controller: _quillController,
                    config: QuillEditorConfig(
                      checkBoxReadOnly: false,
                      padding: const EdgeInsets.all(12),
                      placeholder: 'Digite o conteúdo da nota com formatação aqui...',
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          TextStyle(color: colorScheme.onSurface), 
                          const HorizontalSpacing(0, 0), 
                          const VerticalSpacing(0, 0), 
                          const VerticalSpacing(0, 0),
                          null, 
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
            
            // Botão Adicionar/Remover Imagem
            Row(
              children: [
                TextButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Trocar/Adicionar imagem"),
                ),
                if (imageBytes != null)
                  TextButton.icon(
                    onPressed: removeImage,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text("Remover imagem"),
                  ),
              ],
            ),

            // Pré-visualização da imagem
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