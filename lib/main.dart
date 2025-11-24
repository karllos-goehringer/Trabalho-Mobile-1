import 'package:app_trabalho/models/NotaClass.dart';
import 'package:app_trabalho/models/TarefaClass.dart';
import 'package:app_trabalho/pages/FormAddNotaCard.dart';
import 'package:app_trabalho/widgets/NotaCard.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async  {
  await Hive.initFlutter();
  Hive.registerAdapter(TarefaAdapter());
  var boxAnotacoes = await Hive.openBox<Tarefa>('notaBox');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      themeMode = themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Anotações',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: HomePage(toggleTheme: toggleTheme),
    );
  }
}


class HomePage extends StatelessWidget {
final VoidCallback toggleTheme; 
  const HomePage({super.key, required this.toggleTheme});
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Tarefa>('notaBox'); 

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Anotações')),
      body: ValueListenableBuilder<Box<Tarefa>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Nenhuma anotação encontrada.'));
          }

          final int itemCount = box.length;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final int reversedIndex = itemCount - 1 - index;
              final Tarefa ? nota = box.getAt(reversedIndex);

              if (nota == null) return const SizedBox.shrink();

              return Dismissible(
                key: Key('nota_$reversedIndex'),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.startToEnd,
                onDismissed: (_) async {
                  await box.deleteAt(reversedIndex);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Anotação removida')),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: NoteCard(
                    nota: nota,
                    onTap: () {},
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateNotePage()),
          );
        },
      ),
    );
  }
}