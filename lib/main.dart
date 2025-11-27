
import 'package:NoteTask/models/NotaClass.dart';
import 'package:NoteTask/models/TarefaClass.dart';
import 'package:NoteTask/pages/EditNotaCard.dart';
import 'package:NoteTask/pages/FormAddNotaCard.dart';
import 'package:NoteTask/pages/FormAddTarefaCard.dart';
import 'package:NoteTask/pages/TarefaPage.dart';
import 'package:NoteTask/widgets/NotaCard.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:NoteTask/models/boxes.dart' as boxes;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alarm/alarm.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(NotaAdapter());
  Hive.registerAdapter(TarefaAdapter());
  await Hive.openBox<Nota>('notaBox');
  await Hive.openBox<Tarefa>('tarefaBox');
  boxes.notaBox = Hive.box<Nota>('notaBox');
  boxes.tarefaBox = Hive.box<Tarefa>('tarefaBox');
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.dark;

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
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('pt', 'BR')],
      home: HomePage(toggleTheme: toggleTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomePage({super.key, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box<Nota> notaBox;
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    notaBox = Hive.box<Nota>('notaBox');

    // Inicializa a lista de widgets
    _widgetOptions = <Widget>[
      _NotesContent(notaBox: notaBox),
      const TarefaPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() async {
    final page = _selectedIndex == 0
        ? const CreateNotePage()
        : const CreateTarefaPage();

    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Minhas Anotações' : 'Minhas Tarefas',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),

      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            label: 'Anotações',
            icon: Icon(Icons.note_alt_outlined),
            activeIcon: Icon(Icons.note_alt),
          ),
          BottomNavigationBarItem(
            label: 'Tarefas',
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
          ),
        ],
      ),
    );
  }
}

class _NotesContent extends StatelessWidget {
  final Box<Nota> notaBox;

  const _NotesContent({required this.notaBox});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Nota>>(
      valueListenable: notaBox.listenable(),
      builder: (context, box, _) {
        if (box.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_add, size: 80, color: Colors.grey),
                Text(
                  'Nenhuma anotação registrada!',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Toque no "+" para adicionar uma nova anotação.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        final int itemCount = box.length;
        final reversedKeys = box.keys.toList().reversed.toList();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final key = reversedKeys[index];
            final Nota? nota = box.get(key);

            if (nota == null) return const SizedBox.shrink();
            final dismissibleKey = Key(key.toString());

            return Dismissible(
              key: dismissibleKey,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 16),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.startToEnd,
              onDismissed: (_) async {
                await box.delete(key);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anotação removida')),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                    child: NoteCard(
                  nota: nota,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditNotePage(nota: nota, notaKey: key),
                      ),
                    );
                  },
                  onDelete: () async {
                    await box.delete(key);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anotação removida')),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
