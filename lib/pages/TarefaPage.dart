import 'package:app_trabalho/models/TarefaClass.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// ===================================================
// PLACEHOLDERS (SUBSTITUA PELOS SEUS ARQUIVOS REAIS)
// ===================================================

// Classe Placeholder para Tarefa (models/TarefaClass.dart)


// Adapter Placeholder


// Componente Card Placeholder (widgets/TarefaCard.dart)
// Adaptado para usar a classe Tarefa definida acima
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


// Widget Placeholder para a página de Criação (pages/FormAddNotaCard.dart)
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
    
    // Supondo que você usa 'notaBox' para tarefas também
    final tarefaBox = Hive.box<Tarefa>('tarefaBox');
    await tarefaBox.add(tarefa);
    
    // Retorna para a página anterior
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

// ===================================================
// PÁGINA PRINCIPAL DE TAREFAS
// ===================================================

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
    // Inicializa a box de tarefas
    // É uma boa prática usar uma box separada, mas estou usando 'notaBox'
    // como você indicou no código anterior.
    tarefaBox = Hive.box<Tarefa>('tarefaBox'); 
  }

  // Função para deletar a tarefa
  void _deleteTarefa(dynamic key) async {
    await tarefaBox.delete(key);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarefa removida!')),
      );
    }
  }

  // Função para alternar o status de conclusão
  void _toggleComplete(dynamic key, Tarefa tarefa, bool newValue) async {
    // 1. Cria uma cópia da tarefa com o novo estado de conclusão
    final updatedTarefa = Tarefa(
      titulo: tarefa.titulo,
      momentoCadastro: tarefa.momentoCadastro,
      concluida: newValue, // O novo valor
    );

    // 2. Atualiza a box usando a chave
    await tarefaBox.put(key, updatedTarefa); 
    
    // O ValueListenableBuilder fará o rebuild automaticamente
  }


  @override
  Widget build(BuildContext context) {
    // Acessa a box que contém as Tarefas (Nota no seu setup)
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

          // Obtém as chaves e inverte para mostrar as mais recentes primeiro
          final reversedKeys = box.keys.toList().reversed.toList();
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final key = reversedKeys[index];
              // Tenta obter a Tarefa
              final Tarefa? tarefa = box.get(key); 
              
              if (tarefa == null) return const SizedBox.shrink();

              // Usa o Dismissible para deletar arrastando
              return Dismissible(
                key: Key(key.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteTarefa(key), // Chama a função de deleção
                child: TarefaCard(
                  tarefa: tarefa,
                  onTap: () {
                    // Navega para uma tela de edição (você precisaria criar EditTarefaPage)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Implementar navegação para edição da tarefa')),
                    );
                  },
                  // Passa a função que atualiza o status de conclusão
                  onToggleComplete: (newValue) => _toggleComplete(key, tarefa, newValue),
                  onDelete: () => _deleteTarefa(key), // Deleta com o botão interno
                ),
              );
            },
          );
        },
      ),
      // Botão para adicionar nova tarefa
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTarefaPage()), // Usa a página de criação
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}