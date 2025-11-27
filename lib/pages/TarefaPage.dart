import 'package:NoteTask/models/TarefaClass.dart';
import 'package:alarm/alarm.dart';
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

  String? get _alarmTimeDisplay {
    if (tarefa.dataAlarme == null) {
      return null;
    }
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

    final Color alarmIconColor = tarefa.concluida ? Colors.green : Colors.blue;
    final bool hasAlarm = tarefa.dataAlarme != null;

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
                    if (hasAlarm)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              tarefa.concluida
                                  ? Icons.alarm_off
                                  : Icons.alarm_on,
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
                                decoration: tarefa.concluida
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
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
    //Para garantir que o alarme seja parado ao deletar
    final Tarefa? tarefa = tarefaBox.get(key);
    if (tarefa != null) {
      await Alarm.stop(tarefa.id);
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tarefa removida')));
  }

  void _toggleComplete(dynamic key, Tarefa tarefa, bool newValue) async {
    final updatedTarefa = Tarefa(
      id: tarefa.id,
      titulo: tarefa.titulo,
      momentoCadastro: tarefa.momentoCadastro,
      concluida: newValue,
      dataAlarme: tarefa.dataAlarme,
    );
    await tarefaBox.put(key, updatedTarefa);

    if (newValue == true) {
      await Alarm.stop(tarefa.id);
    }
  }

  void _navigateToEditTask(dynamic key, Tarefa tarefa) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TarefaFormPage(
          tarefa: tarefa,
          hiveKey: key,
        ),
      ),
    );

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
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  Text(
                    'Nenhuma tarefa pendente!',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Toque no "+" para adicionar uma nova tarefa.',
                    style: TextStyle(color: Colors.grey),
                  ),
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
                  onTap: () async {
                    _navigateToEditTask(key, tarefa);
                  },
                  onToggleComplete: (newValue) =>
                      _toggleComplete(key, tarefa, newValue),
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

class TarefaFormPage extends StatefulWidget {
  final Tarefa? tarefa; 
  final dynamic hiveKey; 

  const TarefaFormPage({super.key, this.tarefa, this.hiveKey});

  @override
  State<TarefaFormPage> createState() => _TarefaFormPageState();
}

class _TarefaFormPageState extends State<TarefaFormPage> {
  final _titleController = TextEditingController();
  late bool _concluida;
  late String _momentoCadastro;
  late int _id;

  DateTime? _selectedAlarmDateTime;

  dynamic _tarefaHiveKey;

  @override
  void initState() {
    super.initState();

    _tarefaHiveKey = widget.hiveKey; 

    if (widget.tarefa != null) {
      _id = widget.tarefa!.id;
      _titleController.text = widget.tarefa!.titulo;
      _concluida = widget.tarefa!.concluida;
      _selectedAlarmDateTime = widget.tarefa!.dataAlarme;
      _momentoCadastro = widget.tarefa!.momentoCadastro;
    } else {
      _id = 0; 
      _concluida = false;
      _momentoCadastro = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String get _alarmDisplayTime {
    if (_selectedAlarmDateTime == null) {
      return 'Nenhum alarme definido';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(_selectedAlarmDateTime!);
  }

  Future<void> _pickDateTime() async {
    DateTime initialDate = _selectedAlarmDateTime ?? DateTime.now().add(const Duration(minutes: 1));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        setState(() {
          _selectedAlarmDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _clearAlarm() {
    setState(() {
      _selectedAlarmDateTime = null;
    });
  }

  void saveOrUpdateNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha título!")));
      return;
    }

    final newOrUpdatedTarefa = Tarefa(
      id: widget.tarefa != null ? widget.tarefa!.id : _titleController.text.hashCode, 
      titulo: _titleController.text,
      momentoCadastro: _momentoCadastro,
      concluida: _concluida,
      dataAlarme: _selectedAlarmDateTime,
    );

    final tarefaBox = Hive.box<Tarefa>('tarefaBox');

    //Sempre tenta parar o alarme antigo, caso o ID não tenha mudado.
    await Alarm.stop(newOrUpdatedTarefa.id); 

    if (widget.tarefa != null) {
      await tarefaBox.put(_tarefaHiveKey, newOrUpdatedTarefa);
    } else {
      await tarefaBox.add(newOrUpdatedTarefa);
    }

    //Lógica de SET do Alarme
    if (newOrUpdatedTarefa.dataAlarme != null && newOrUpdatedTarefa.dataAlarme!.isAfter(DateTime.now()) && !newOrUpdatedTarefa.concluida) {
      final settings = AlarmSettings(
        id: newOrUpdatedTarefa.id,
        dateTime: newOrUpdatedTarefa.dataAlarme!,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: false,
        vibrate: true,
        notificationSettings: NotificationSettings(
          title: 'Lembrete de Tarefa!',
          body: '${newOrUpdatedTarefa.titulo}',
        ),
        volumeSettings: VolumeSettings.fade(
          fadeDuration: const Duration(seconds: 20),
        ),
      );
      await Alarm.set(alarmSettings: settings);
    }

    Navigator.pop(context, newOrUpdatedTarefa);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.tarefa != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Tarefa" : "Nova Tarefa"),
        actions: [
          IconButton(
            onPressed: saveOrUpdateNote,
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
              decoration: const InputDecoration(labelText: "Título"),
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
            const Divider(),
            ListTile(
              title: const Text('Definir Alarme'),
              subtitle: Text(_alarmDisplayTime),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.alarm_add, color: Colors.blue),
                    onPressed: _pickDateTime,
                  ),
                  if (_selectedAlarmDateTime != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: _clearAlarm,
                    ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}