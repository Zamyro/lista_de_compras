import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class CampoPreco extends StatefulWidget {
  final double? valorInicial;
  final Function(double) onSaved;

  const CampoPreco({
    Key? key,
    this.valorInicial,
    required this.onSaved
  }) : super(key: key);

  @override
  State<CampoPreco> createState() => _CampoPrecoState();
}

class _CampoPrecoState extends State<CampoPreco> {
  late MoneyMaskedTextController _controller;

  
  @override
  void initState() {
    super.initState();
    _controller = MoneyMaskedTextController(
      leftSymbol: 'R\$ ',
      decimalSeparator: ',',
      thousandSeparator: '.',
      initialValue: widget.valorInicial ?? 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Preço',
        hintText: 'R\$ 0,00',
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) {
        widget.onSaved(_controller.numberValue);
      },
    );
  }
}
