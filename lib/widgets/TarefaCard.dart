import 'package:flutter/material.dart';
import '../models/TarefaClass.dart'; // Importamos o modelo Tarefa

class TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onTap;
  // A função que será chamada quando o usuário tocar no Checkbox
  final Function(bool) onToggleComplete;
  final VoidCallback onDelete;

  const TarefaCard({
    super.key,
    required this.tarefa,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Estilo para tarefas concluídas (texto riscado e cor de destaque)
    final TextStyle titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      decoration: tarefa.concluida ? TextDecoration.lineThrough : TextDecoration.none,
      color: tarefa.concluida ? Colors.grey : Theme.of(context).textTheme.titleLarge?.color,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Adiciona uma borda colorida se a tarefa estiver concluída
        side: BorderSide(
          color: tarefa.concluida ? Colors.green.shade600 : Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap, // Abre a página de edição/detalhes
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              // Checkbox Interativo para marcar como concluída
              Checkbox(
                value: tarefa.concluida,
                onChanged: (bool? newValue) {
                  // Chama a função passada pelo widget pai para atualizar o estado no Hive
                  onToggleComplete(newValue ?? false); 
                },
                activeColor: Colors.green,
              ),
              const SizedBox(width: 8),

              // Título e data
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarefa.titulo,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Criada em: ${tarefa.momentoCadastro}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              // Botão de Exclusão (opcional, mas útil para o card)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}