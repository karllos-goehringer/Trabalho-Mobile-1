import 'package:hive/hive.dart';
part 'TarefaClass.g.dart';

@HiveType(typeId: 2)
class Tarefa {
  Tarefa({
    required this.id,
    required this.titulo,
    required this.concluida,
    required this.momentoCadastro,
    this.dataAlarme,
  });

  @HiveField(0)
  int id;

  @HiveField(1)
  String titulo;

  @HiveField(2)
  bool concluida;

  @HiveField(3)
  String momentoCadastro;

  @HiveField(4)
  DateTime? dataAlarme; // pode ser nulo!
}