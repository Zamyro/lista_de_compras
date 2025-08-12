import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lista_de_compras/models/produto.dart';
import 'lista_compras_page.dart';
import 'configuracoes_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProdutoAdapter());
  await Hive.openBox<String>('listas');
  
  var listasBox = Hive.box<String>('listas');
  if (listasBox.isEmpty) listasBox.add("Lista Principal");
  for (var nome in listasBox.values) {
    await Hive.openBox<Produto>('produtos_$nome');
  }

  runApp(ListaComprasApp());
}

class ListaComprasApp extends StatefulWidget {
  @override
  State<ListaComprasApp> createState() => _ListaComprasAppState();
}

class _ListaComprasAppState extends State<ListaComprasApp> {
  bool modoEscuro = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: modoEscuro ? ThemeMode.dark : ThemeMode.light,
      home: ListaComprasPage(
        onToggleTheme: () {
          setState(() {
            modoEscuro = !modoEscuro;
          });
        },
        modoEscuro: modoEscuro,
      ),
      routes: {
        '/config': (context) => ConfigPage(),
      },
    );
  }
}
