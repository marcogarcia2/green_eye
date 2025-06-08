import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/estufa_card.dart';

class EstufaStorage {
  static const _key = 'estufas_adicionadas';

  static Future<void> saveEstufas(List<EstufaCard> estufas) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = estufas.map((e) => _estufaToJson(e)).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<EstufaCard>> loadEstufas() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => _estufaFromJson(e)).toList();
  }

  static Future<void> clearEstufas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Map<String, dynamic> _estufaToJson(EstufaCard e) => {
    'id': e.id,
    'nome': e.nome,
    'sensores': e.sensores,
    'historico': e.historico,
    'alertas': e.alertas,
  };

  static EstufaCard _estufaFromJson(Map<String, dynamic> json) => EstufaCard(
    id: json['id'],
    nome: json['nome'],
    sensores: Map<String, double>.from(json['sensores'] ?? {}),
    historico: (json['historico'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, List<double>.from(v))) ?? {},
    alertas: (json['alertas'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, Map<String, double>.from(v))) ?? {},
  );
}
