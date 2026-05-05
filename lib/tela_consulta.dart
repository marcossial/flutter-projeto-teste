import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaConsulta extends StatefulWidget {
  @override
  _TelaConsultaState createState() => _TelaConsultaState();
}

class _TelaConsultaState extends State<TelaConsulta> {
  final CollectionReference _clientes =
  FirebaseFirestore.instance.collection('clientes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consultar clientes"),
      ),
      body: StreamBuilder(
        stream: _clientes.orderBy('nome').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasError) {
            return Center(child: Text("Erro ao carregar dados: ${streamSnapshot.error}"));
          }

          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
            return Center(child: Text("Nenhum cliente cadastrado."));
          }

          return ListView.builder(
            itemCount: streamSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(documentSnapshot['nome'][0].toString().toUpperCase()),
                  ),
                  title: Text(documentSnapshot['nome']),
                  subtitle: Text(documentSnapshot['email']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletarCliente(documentSnapshot.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deletarCliente(String id) async {
    await _clientes.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Cliente removido!")),
    );
  }
}