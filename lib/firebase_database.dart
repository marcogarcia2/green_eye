import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseDatabaseService {
  static final FirebaseDatabaseService _instance = FirebaseDatabaseService._internal();

  factory FirebaseDatabaseService() => _instance;

  FirebaseDatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Exemplo de método para buscar usuários
  Future<List<Map<String, dynamic>>> getUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // outros métodos de leitura/escrita aqui
}