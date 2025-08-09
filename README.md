# Lista de Compras - Flutter App

Um aplicativo simples e prático para gerenciar sua **lista de compras**, desenvolvido em **Flutter** e com armazenamento local usando **Hive**.
Ideal para quem quer manter suas compras organizadas de forma rápida e intuitiva.

---

## Funcionalidades

*  **Adicionar produtos** à lista de compras
*  **Remover produtos** facilmente
*  **Armazenamento local** (mesmo fechando o app, sua lista é salva)
*  **Gerar PDF** com todos os itens da lista
*  Interface simples e intuitiva

---

## Preview

*(Adicionarei prints aqui posteriormente)*

---

## Tecnologias Utilizadas

* **[Flutter](https://flutter.dev/)**
* **[Hive](https://pub.dev/packages/hive)** - Banco de dados local
* **[pdf](https://pub.dev/packages/pdf)** - Geração de PDF

---

## Como Instalar

1. **Clone este repositório**

   ```bash
   git clone https://github.com/Zamyro/lista_de_compras.git
   ```
2. **Acesse a pasta do projeto**

   ```bash
   cd lista_de_compras
   ```
3. **Instale as dependências**

   ```bash
   flutter pub get
   ```
4. **Execute o app**

   ```bash
   flutter run
   ```

---

## Estrutura do Projeto

```
lib/
  models/
    ├── lista_compras.dart    # Arquivo para uso futuro
    ├── lista_compras.g.dart  # Gerado automaticamente pelo comando build_runner. Não editar manualmente.
    ├── produto.dart          # Representa o modelo de dados de um produto da lista de compras.
    ├── produto.g.dart        # Gerado automaticamente pelo comando build_runner. Não editar manualmente.
  ├── main.dart               # Ponto de entrada do app
  ├── pdf_generator.dart      # Serviço para gerar PDF
assets/
  └── app_logo.png     # Logo do aplicativo
```

---

## Gerando PDF

Basta clicar no botão **"Gerar PDF"** no canto superior direito.
O documento gerado conterá **todos os itens da sua lista** e ficará disponível para compartilhamento.

---

## Ideias Futuras

*  Criar múltiplas listas de compras
*  Sugestão automática de produtos ao digitar
*  Sincronização em nuvem
*  Permitir que duas ou mais pessoas editem a mesma lista em tempo real

---

## Frase do App

> "*Nunca subestime o poder de uma lista de compras… e de um pato curioso.*" 🦆

