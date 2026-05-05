import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaAdicionar extends StatefulWidget {
  @override
  _TelaAdicionarState createState() => _TelaAdicionarState();
}

class _TelaAdicionarState extends State<TelaAdicionar> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  bool _carregando = false;

  Future<void> _salvarNoFirestore() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      try {
        await FirebaseFirestore.instance.collection('clientes').add({
          'nome': _nomeController.text,
          'email': _emailController.text,
          'data_registro': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente salvo com sucesso!'), backgroundColor: Colors.green),
        );

        _nomeController.clear();
        _emailController.clear();
        Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registrar cliente")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: "Nome do Cliente",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || !value.contains("@")) ? "E-mail inválido" : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _carregando ? null : _salvarNoFirestore,
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: _carregando
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Salvar no Firebase"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}