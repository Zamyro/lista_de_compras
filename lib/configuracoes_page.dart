import 'package:flutter/material.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool notificacoesAtivadas = true;
  bool temaEscuro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Notificações"),
            value: notificacoesAtivadas,
            onChanged: (value) {
              setState(() {
                notificacoesAtivadas = value;
              });
            },
          ),
          SwitchListTile(
            title: Text("Tema Escuro"),
            value: temaEscuro,
            onChanged: (value) {
              setState(() {
                temaEscuro = value;
              });
            },
          ),
          ListTile(
            title: Text("Sobre o aplicativo"),
            subtitle: Text("Versão 1.0.0"),
            leading: Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
