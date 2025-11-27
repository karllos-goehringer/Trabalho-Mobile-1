import 'package:NoteTask/models/TarefaClass.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart'; 
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class CreateTarefaPage extends StatefulWidget {
  final Tarefa? tarefaOriginal;
  final dynamic tarefaKey;

  const CreateTarefaPage({
    super.key,
    this.tarefaOriginal,
    this.tarefaKey,
  });

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

  @override
  void initState() {
    super.initState();
    if (widget.tarefaOriginal != null) {
      _titleController.text = widget.tarefaOriginal!.titulo;
      _concluida = widget.tarefaOriginal!.concluida;
      _selectedAlarmDateTime = widget.tarefaOriginal!.dataAlarme;
    }
  }

  String get _alarmDisplayTime {
    if (_selectedAlarmDateTime == null) {
      return 'Nenhum alarme definido';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(_selectedAlarmDateTime!);
  }

  Future<void> _pickDateTime() async {
    DateTime initialDate =
        _selectedAlarmDateTime ?? DateTime.now().add(const Duration(minutes: 1));

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

  void saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha título!")));
      return;
    }

    //Usa o ID original se estiver editando, senão gera um novo
    final int taskId = widget.tarefaOriginal?.id ?? _titleController.text.hashCode;

    final tarefa = Tarefa(
      id: taskId,
      titulo: _titleController.text,
      //Usa a data original se estiver editando
      momentoCadastro: widget.tarefaOriginal?.momentoCadastro ?? _selectedDate, 
      concluida: _concluida,
      dataAlarme: _selectedAlarmDateTime,
    );

    final tarefaBox = Hive.box<Tarefa>('tarefaBox');

    //(PUT para editar, ADD para criar)
    if (widget.tarefaKey != null) {
      await tarefaBox.put(widget.tarefaKey, tarefa);
    } else {
      await tarefaBox.add(tarefa);
    }

    // 4. Lógica do Alarme (SET ou STOP)
    final bool shouldSetAlarm = tarefa.dataAlarme != null &&
        tarefa.dataAlarme!.isAfter(DateTime.now()) &&
        !tarefa.concluida;

    if (shouldSetAlarm) {
      final settings = AlarmSettings(
        id: tarefa.id,
        dateTime: tarefa.dataAlarme!,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: false,
        vibrate: true,
        notificationSettings:
            NotificationSettings(title: 'Lembrete de Tarefa!', body: '${tarefa.titulo}'),
        volumeSettings: VolumeSettings.fade(fadeDuration: Duration(seconds: 20)),
      );

      await Alarm.set(alarmSettings: settings);
    } else if (widget.tarefaOriginal != null) {
      // Se não deve tocar o alarme (tarefa concluída ou alarme removido), pare o alarme antigo
      await Alarm.stop(tarefa.id);
    }

    Navigator.pop(context, tarefa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tarefaOriginal != null ? "Editar Tarefa" : "Nova Tarefa"),
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