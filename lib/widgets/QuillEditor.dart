import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

// Este widget encapsula a Barra de Ferramentas e o Editor Quill.
// Ele recebe o controller como argumento e mantém a UI limpa e modular.
class QuillEditorWidget extends StatelessWidget {
  final QuillController controller;
  final double editorHeight;

  const QuillEditorWidget({
    super.key,
    required this.controller,
    this.editorHeight = 300, // Altura padrão do editor de texto
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra de ferramentas do Quill
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            // Cantos arredondados apenas no topo para se alinhar com o editor abaixo
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)), 
          ),
          child: QuillSimpleToolbar(
            controller: controller,
            config: const QuillSimpleToolbarConfig(
              // Configurações para simplificar a barra de ferramentas
              showAlignmentButtons: false,
              showSearchButton: false,
              showColorButton: true,
              showBackgroundColorButton: true,
              multiRowsDisplay: true, // Permite mais espaço para os botões
            ),
          ),
        ),
        
        // Editor de texto rico do Quill
        Container(
          height: editorHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            // Cantos arredondados apenas na base
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
          ),
          child: QuillEditor(
            controller: controller,
            config: const QuillEditorConfig(
              checkBoxReadOnly: false,
              padding: EdgeInsets.all(12),
              placeholder: 'Digite o conteúdo da sua nota aqui...',
            ),
            focusNode: FocusNode(),
            scrollController: ScrollController(),
          ),
        ),
      ],
    );
  }
}