import 'package:app_trabalho/models/TarefaClass.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class CreateTarefaPage extends StatefulWidget {
  const CreateTarefaPage({super.key});

  @override
  State<CreateTarefaPage> createState() => _CreateTarefaPageState();
}

class _CreateTarefaPageState extends State<CreateTarefaPage> {
  final _titleController = TextEditingController();
  bool _concluida = false; 

  final String _selectedDate =
      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());


  void saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha título!"),
        ),
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
    Navigator.pop(context, tarefa);
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
              decoration: const InputDecoration(
                labelText: "Título",
              ),
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
          ],
        ),
      ),
    );
  }
}