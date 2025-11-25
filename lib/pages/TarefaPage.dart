import 'package:app_trabalho/models/TarefaClass.dart';
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

  @override
  Widget build(BuildContext context) {
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
        side: BorderSide(
          color: tarefa.concluida ? Colors.green.shade600 : Theme.of(context).dividerColor.withOpacity(0.5),
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
class CreateTarefaPage extends StatefulWidget {
  const CreateTarefaPage({super.key});

  @override
  State<CreateTarefaPage> createState() => _CreateTarefaPageState();
}

class _CreateTarefaPageState extends State<CreateTarefaPage> {
  final _titleController = TextEditingController();
  bool _concluida = false; 

  final String _selectedDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

  void saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha título!")),
      );
      return;
    }

    final tarefa = Tarefa(
      titulo: _titleController.text,
      momentoCadastro: _selectedDate,
      concluida: _concluida, 
    );
    final tarefaBox = Hive.box<Tarefa>('tarefaBox');
    await tarefaBox.add(tarefa);
    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Tarefa"),
        actions: [
          IconButton(
            onPressed: saveNote,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Título da Tarefa"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _concluida,
                  onChanged: (bool? newValue) {
                    setState(() { 
                      _concluida = newValue ?? false;
                    });
                  },
                ),
                const Text("Tarefa Concluída"),
              ],
            ),
            const SizedBox(height: 20),
            // Aqui é onde você adicionaria mais campos, como data de vencimento, etc.
          ],
        ),
      ),
    );
  }
}


class TarefaPage extends StatefulWidget {
  const TarefaPage({super.key});

  @override
  State<TarefaPage> createState() => _TarefaPageState();
}

class _TarefaPageState extends State<TarefaPage> {
  late Box<Tarefa> tarefaBox;

  @override
  void initState() {
    super.initState();
    tarefaBox = Hive.box<Tarefa>('tarefaBox'); 
  }
  void _deleteTarefa(dynamic key) async {
    await tarefaBox.delete(key);
    ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(content: Text('Tarefa removida')),
    );
  }
  void _toggleComplete(dynamic key, Tarefa tarefa, bool newValue) async {
    final updatedTarefa = Tarefa(
      titulo: tarefa.titulo,
      momentoCadastro: tarefa.momentoCadastro,
      concluida: newValue,
    );
    await tarefaBox.put(key, updatedTarefa); 
  }


  @override
  Widget build(BuildContext context) {
    final box = tarefaBox;
    return Scaffold(
      body: ValueListenableBuilder<Box<Tarefa>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
                  Text('Nenhuma tarefa pendente!', style: TextStyle(fontSize: 18)),
                  Text('Toque no "+" para adicionar uma nova tarefa.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          final reversedKeys = box.keys.toList().reversed.toList();
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = reversedKeys[index];
              final Tarefa? tarefa = box.get(key); 
              if (tarefa == null) return const SizedBox.shrink();
              return Dismissible(
                key: Key(key.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteTarefa(key),
                child: TarefaCard(
                  tarefa: tarefa,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Implementar navegação para edição da tarefa')),
                    );
                  },
                  onToggleComplete: (newValue) => _toggleComplete(key, tarefa, newValue),
                  onDelete: () => _deleteTarefa(key),
                ),
              );
            },
          );
        },
      ),
      
    );
  }
}