import 'package:app_trabalho/models/NotaClass.dart';
import 'package:app_trabalho/pages/EditNotaCard.dart';
import 'package:app_trabalho/pages/FormAddNotaCard.dart';
import 'package:app_trabalho/widgets/NotaCard.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
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
      localizationsDelegates: const [
        // Delegados globais (padrão)
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // Inglês como fallback
        Locale('pt', 'BR'), // Português (se você quiser a tradução do Quill)
      ],
      home: HomePage(toggleTheme: toggleTheme),
    );
  }
}
class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme; // Mantém a propriedade para trocar o tema

  const HomePage({super.key, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // A box Hive, inicializada no initState da sua aplicação principal
  late Box<Nota> notaBox;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    // É crucial que a box esteja aberta antes de tentar usá-la
    notaBox = Hive.box<Nota>('notaBox'); 
  }
  // Função para mudar o índice selecionado
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    // Acessa a box diretamente aqui, já que está inicializada
    final box = notaBox; 
    final bool isNotesPage = _selectedIndex == 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Anotações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme, // Acesso via widget.toggleTheme
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Nota>>(
        valueListenable: box.listenable(),
        builder: (context, box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Nenhuma anotação encontrada.'));
          }

          final int itemCount = box.length;
          // Invertendo a ordem para exibir as notas mais recentes primeiro
          final reversedKeys = box.keys.toList().reversed.toList();
          
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final key = reversedKeys[index];
              final Nota? nota = box.get(key); // Obtém a nota pela chave
              
              if (nota == null) return const SizedBox.shrink();

              // Como estamos usando a chave real do Hive, vamos usar o key para o Dismissible
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
                  await box.delete(key); // Deleta pela chave
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
                    
                    // 2. CORREÇÃO DE RENDERIZAÇÃO: Torna o onTap assíncrono
                    onTap: () async {
                      // Aguarda o retorno da EditNotePage
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditNotePage(nota: nota),
                        ),
                      );
                      
                      // Força a re-renderização do widget pai (HomePage) 
                      // para garantir que a nota mais atualizada seja exibida, 
                      // caso o ValueListenableBuilder não tenha reagido imediatamente.
                      setState(() {
                        // O corpo vazio é suficiente para forçar a reconstrução
                      });
                    },
                    
                    onDelete: () async {
                      // Usando o .delete(key) é mais seguro que .deleteAt()
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
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Também adicionamos await e setState aqui para garantir que a lista atualize
          // se você voltar da página de criação
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateNotePage()),
          );
          
          setState(() {}); 
        },
      ),
     bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Chamamos o método para mudar o estado
        selectedItemColor: Theme.of(context).colorScheme.primary, // Cor quando selecionado
        unselectedItemColor: Colors.grey, // Cor quando não selecionado
        items: const [
          BottomNavigationBarItem(
            label: 'Anotações',
            icon: Icon(Icons.note_alt_outlined),
            activeIcon: Icon(Icons.note_alt),
          ),
          BottomNavigationBarItem(
            label: 'Tarefas',
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
          ),
        ],
      ),
    );
  }
}