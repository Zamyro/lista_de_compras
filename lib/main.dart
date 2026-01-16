import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:duck_it/home_page.dart';
import 'package:duck_it/models/ingredientes.dart';
import 'package:duck_it/models/produto.dart';
import 'package:duck_it/models/receitas.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MarcaAdapter());
  Hive.registerAdapter(ProdutoAdapter());
  Hive.registerAdapter(IngredienteAdapter());
  Hive.registerAdapter(ReceitaAdapter());
  await Hive.openBox<String>('listas');
  await Hive.openBox<Receita>('receitas');
  await Hive.openBox<Ingrediente>('ingredientes');

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
      debugShowCheckedModeBanner: false,
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
      home: HomePage(
        onToggleTheme: () {
          setState(() {
            modoEscuro = !modoEscuro;
          });
        },
        modoEscuro: modoEscuro,
      ),
      // themeMode: modoEscuro ? ThemeMode.dark : ThemeMode.light,
      // home: ListaComprasPage(
      //   onToggleTheme: () {
      //     setState(() {
      //       modoEscuro = !modoEscuro;
      //     });
      //   },
      //   modoEscuro: modoEscuro,
      // ),
      // routes: {
      //   '/config': (context) => ConfigPage(),
      // },
    );
  }
}
