import 'package:NoteTask/models/TarefaClass.dart';
import 'package:alarm/alarm.dart';
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
  
  DateTime? _selectedAlarmDateTime;

  final String _selectedDate = DateFormat(
    'dd/MM/yyyy HH:mm',
  ).format(DateTime.now());

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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      
      final TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDate);

      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        // Combinar data e hora
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

  // Método para limpar a data/hora do alarme
  void _clearAlarm() {
    setState(() {
      _selectedAlarmDateTime = null;
    });
  }

  void saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha título!")));
      return;

    }

    final tarefa = Tarefa(
      id: _titleController.hashCode,
      titulo: _titleController.text,
      momentoCadastro: _selectedDate,
      concluida: _concluida,
      dataAlarme: _selectedAlarmDateTime, 
    );
    
    final tarefaBox = Hive.box<Tarefa>('tarefaBox');
    await tarefaBox.add(tarefa);
    
    if (tarefa.dataAlarme != null && tarefa.dataAlarme!.isAfter(DateTime.now()) && !tarefa.concluida) {

      final settings = AlarmSettings(
        id: tarefa.id,
        dateTime: tarefa.dataAlarme!,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: false,
        vibrate: true,
        notificationSettings: NotificationSettings(title: 'Lembrete de Tarefa!', body: '${tarefa.titulo}'),
        volumeSettings: VolumeSettings.fade(fadeDuration: Duration(seconds: 20)),
      );

      await Alarm.set(alarmSettings: settings);
    }
    
    Navigator.pop(context, tarefa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Tarefa"),
        actions: [
          IconButton(onPressed: saveNote, icon: const Icon(Icons.check)),
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