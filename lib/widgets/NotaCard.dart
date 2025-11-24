import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'; 
import '../models/NotaClass.dart';

class NoteCard extends StatefulWidget {
  final Nota nota;
  final VoidCallback? onTap; 
  final VoidCallback? onDelete; 

  const NoteCard({
    super.key,
    required this.nota,
    this.onTap,
    this.onDelete,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _initializeQuillController();
  }
  
  // CORREÇÃO ESSENCIAL: Garante que o controlador seja reinicializado
  // se o texto da nota mudar, mesmo que o objeto HiveObject seja o mesmo.
  @override
  void didUpdateWidget(covariant NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 1. Obtém o JSON do texto mais atualizado que veio do widget pai (HomePage)
    final String newTextJson = widget.nota.texto;
    
    // 2. Obtém o JSON do texto que está ATUALMENTE no controlador
    // Serializamos o conteúdo do controlador para podermos comparar com a string JSON da Nota.
    final String currentControllerTextJson = jsonEncode(_quillController.document.toDelta().toJson());

    // 3. Compara: Se o conteúdo novo da Nota for diferente do que está no controlador, atualiza.
    if (newTextJson != currentControllerTextJson) {
      // Dispomos o controlador antigo
      _quillController.dispose(); 
      // Criamos um novo controlador com o conteúdo mais recente
      _initializeQuillController();
    }
  }
  
  void _initializeQuillController() {
    try {
      final docJson = jsonDecode(widget.nota.texto);
      final document = Document.fromJson(docJson);
      _quillController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // Fallback em caso de JSON inválido
      final document = Document()..insert(0, 'Erro ao carregar conteúdo de texto rico.');
      _quillController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(fontSize: 16, color: colorScheme.onSurface);
    
    final customStyles = DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        textStyle,
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        null,
      ),
      h1: DefaultTextBlockStyle(
        textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(16, 0),
        const VerticalSpacing(0, 0),

        null,
      ),
      
    );

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e Botão Deletar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.nota.titulo,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                  )
                ],
              ),

              const SizedBox(height: 8),

              // Momento do Cadastro
              Text(
                "Criado em: ${widget.nota.momentoCadastro}",
                style: TextStyle(
                  fontSize: 13, 
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 12),

              // Pré-visualização do conteúdo Quill
              SizedBox(
                height: 100, 
                child: AbsorbPointer( 
                  child: QuillEditor.basic(
                    config: QuillEditorConfig(
                      checkBoxReadOnly: false, 
                      padding: EdgeInsets.zero,
                      showCursor: false,
                      customStyles: customStyles, 
                    ),
                    controller: _quillController,
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),

              // Pré-visualização da imagem
              if (widget.nota.imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    widget.nota.imageBytes!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}