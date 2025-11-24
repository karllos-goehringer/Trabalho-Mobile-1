import 'dart:io';
import 'package:flutter/material.dart';
import '../models/NotaClass.dart';

class NoteCard extends StatelessWidget {
  final Nota nota;
  final VoidCallback? onTap;
  final VoidCallback? onDelete; // <-- callback para deletar

  const NoteCard({
    super.key,
    required this.nota,
    this.onTap,
    this.onDelete, // <-- recebe a função
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      nota.titulo,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  )
                ],
              ),

              const SizedBox(height: 8),

              Text(
                "Criado em: ${nota.momentoCadastro}",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),

              const SizedBox(height: 12),

              Text(
                nota.texto,
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              if (nota.imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    nota.imageBytes!,
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
