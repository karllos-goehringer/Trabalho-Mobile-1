import 'dart:io';
import 'package:app_trabalho/models/NotaClass.dart';
import 'package:app_trabalho/models/TarefaClass.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class CreateTarefaPage extends StatefulWidget {
  const CreateTarefaPage({super.key});

  @override
  State<CreateTarefaPage> createState() => _CreateTarefaPageState();
}

class _CreateTarefaPageState extends State<CreateTarefaPage> {
  final _titleController = TextEditingController();
  // 1. Variável de estado para o Checkbox
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
      // 4. Usar o estado do Checkbox
      concluida: _concluida, 
    );
    
    // --- SALVAR NO HIVE (nome correto: notaBox) ---
    final notaBox = Hive.box<Tarefa>('notaBox');
    await notaBox.add(tarefa);
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
            // 2. Adicionar o Checkbox
            Row(
              children: [
                Checkbox(
                  value: _concluida,
                  onChanged: (bool? newValue) {
                    // 3. Atualizar o estado
                    setState(() { 
                      _concluida = newValue ?? false;
                    });
                  },
                ),
                const Text("Tarefa Concluída"),
              ],
            ),
            // Alternativamente, use CheckboxListTile:
            /*
            CheckboxListTile(
              title: const Text("Tarefa Concluída"),
              value: _concluida,
              onChanged: (bool? newValue) {
                setState(() {
                  _concluida = newValue ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading, // Para mover o checkbox para o início
            ),
            */
          ],
        ),
      ),
    );
  }
}