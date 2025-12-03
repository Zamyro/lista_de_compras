import 'package:flutter/material.dart';
import 'package:duck_it/listas_page.dart';
import 'receitas_page.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool modoEscuro;

  const HomePage({
    Key? key,
    required this.onToggleTheme,
    required this.modoEscuro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // appBar: AppBar(
      //   backgroundColor: const Color.fromARGB(100, 0, 195, 255),
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: Icon(modoEscuro ? Icons.dark_mode : Icons.light_mode),
      //       onPressed: onToggleTheme,
      //     ),
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset('assets/logo.png', fit: BoxFit.fill, height: 300),
            ),

            const SizedBox(height: 20),

            const Text(
              "O que você deseja acessar?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            _buildCard(
              context,
              icon: Icons.shopping_cart,
              title: "Lista de Compras",
              color: Colors.pinkAccent,
              page: const ListasPage(),
            ),

            const SizedBox(height: 30),

            _buildCard(
              context,
              icon: Icons.restaurant_menu,
              title: "Receitas",
              color: Colors.orangeAccent,
              page: const ReceitasPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
