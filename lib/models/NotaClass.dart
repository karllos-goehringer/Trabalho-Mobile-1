import 'package:hive/hive.dart';
import 'dart:typed_data';
part 'NotaClass.g.dart';

@HiveType(typeId: 1)
class Nota {
  Nota({
    required this.id,
    required this.titulo,
    required this.texto,
    required this.momentoCadastro,
    this.imageBytes,
  });
  @HiveField(0)
  int id;
  @HiveField(1)
  String titulo;
  @HiveField(2)
  String texto;
  @HiveField(3)
  String momentoCadastro;
  @HiveField(4)
  Uint8List? imageBytes;
}
