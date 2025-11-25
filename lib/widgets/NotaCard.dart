import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/NotaClass.dart';

class NoteCard extends StatelessWidget {
  final Nota nota;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.nota,
    required this.onTap,
    required this.onDelete,
  });

  // Função utilitária para obter a pré-visualização do texto
  String _getPlainTextPreview(String richTextJson) {
    try {
      final json = jsonDecode(richTextJson);
      final document = Document.fromJson(json);
      // Retorna o texto simples, limitando o tamanho
      String text = document.toPlainText().replaceAll('\n', ' ').trim();
      return text.length > 150 ? '${text.substring(0, 150)}...' : text;
    } catch (e) {
      return "Conteúdo indisponível. Erro ao carregar texto rico.";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtém a pré-visualização do corpo da nota
    final bodyPreview = _getPlainTextPreview(nota.texto);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                nota.titulo,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),

              // Pré-visualização do corpo
              Text(
                bodyPreview,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Imagem de pré-visualização (se existir)
              if (nota.imageBytes != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    nota.imageBytes!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Criado em: ${nota.momentoCadastro}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}