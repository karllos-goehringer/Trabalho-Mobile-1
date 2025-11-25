import 'package:NoteTask/models/TarefaClass.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TarefaCard extends StatelessWidget {
  final Tarefa tarefa;
  final VoidCallback onTap;
  final Function(bool) onToggleComplete;
  final VoidCallback onDelete;

  const TarefaCard({
    super.key,
    required this.tarefa,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  // Getter para formatar a data/hora do alarme
  String? get _alarmTimeDisplay {
    if (tarefa.dataAlarme == null) {
      return null;
    }
    // Formata o DateTime para exibição (ex: 25/11/2025 15:30)
    return DateFormat('dd/MM/yyyy HH:mm').format(tarefa.dataAlarme!);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      decoration: tarefa.concluida
          ? TextDecoration.lineThrough
          : TextDecoration.none,
      color: tarefa.concluida
          ? Colors.grey
          : Theme.of(context).textTheme.titleLarge?.color,
    );
    
    // Define a cor do ícone do alarme: verde se concluída, azul se pendente
    final Color alarmIconColor = tarefa.concluida ? Colors.green : Colors.blue;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: tarefa.concluida
              ? Colors.green.shade600
              : Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Checkbox(
                value: tarefa.concluida,
                onChanged: (bool? newValue) {
                  onToggleComplete(newValue ?? false);
                },
                activeColor: Colors.green,
              ),
              const SizedBox(width: 8),
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
                    // ADICIONA A VISUALIZAÇÃO DO ALARME AQUI
                    if (tarefa.dataAlarme != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              tarefa.concluida ? Icons.alarm_off : Icons.alarm_on,
                              color: alarmIconColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Alarme: ${_alarmTimeDisplay!}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: alarmIconColor,
                                decoration: tarefa.concluida ? TextDecoration.lineThrough : TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
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