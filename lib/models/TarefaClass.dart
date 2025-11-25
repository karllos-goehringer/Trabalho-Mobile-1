import 'package:hive/hive.dart';
part 'TarefaClass.g.dart';
@HiveType(typeId: 2)
class Tarefa {
    Tarefa({
    required this.titulo,
    required this.concluida,
    required this.momentoCadastro
  });
  @HiveField(0)
  String titulo;
  @HiveField(1)
  bool concluida;
  @HiveField(2)
  String momentoCadastro;
}