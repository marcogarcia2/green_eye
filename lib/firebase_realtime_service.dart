import 'package:firebase_database/firebase_database.dart';

class FirebaseRealtimeService {
  /// Busca as medições de um dia específico para uma estufa
  Future<Map<String, Map<String, double>>> getMedicoesDoDia(String estufaId, String date) async {
    final snapshot = await _db.child('$estufaId/$date').get();
    if (!snapshot.exists) return {};
    final sensores = Map<String, dynamic>.from(snapshot.value as Map);
    final Map<String, Map<String, double>> sensoresMap = {};
    for (final sensor in ['temp', 'hum', 'moist', 'lum']) {
      if (sensores[sensor] is Map) {
        final horarios = Map<String, dynamic>.from(sensores[sensor]);
        final Map<String, double> horariosMap = {};
        for (final h in horarios.entries) {
          final v = h.value;
          horariosMap[h.key] = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
        }
        sensoresMap[sensor] = horariosMap;
      }
    }
    return sensoresMap;
  }
  /// Busca as datas disponíveis para uma estufa (chaves de dias)
  Future<List<String>> getDatasDisponiveis(String estufaId) async {
    final snapshot = await _db.child(estufaId).get();
    if (!snapshot.exists) return [];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final datas = data.keys.where((k) => k != 'name' && k != 'password').toList();
    datas.sort();
    return datas;
  }
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Busca todas as medições de todos os dias para uma estufa
  Future<Map<String, Map<String, Map<String, double>>>> getAllMedicoes(String estufaId) async {
    final snapshot = await _db.child(estufaId).get();
    if (!snapshot.exists) return {};
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final Map<String, Map<String, Map<String, double>>> result = {};
    for (final entry in data.entries) {
      final date = entry.key;
      if (date == 'name' || date == 'password') continue;
      if (entry.value is Map) {
        final sensores = Map<String, dynamic>.from(entry.value);
        final Map<String, Map<String, double>> sensoresMap = {};
        for (final sensor in ['temp', 'hum', 'moist', 'lum']) {
          if (sensores[sensor] is Map) {
            final horarios = Map<String, dynamic>.from(sensores[sensor]);
            final Map<String, double> horariosMap = {};
            for (final h in horarios.entries) {
              final v = h.value;
              horariosMap[h.key] = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
            }
            sensoresMap[sensor] = horariosMap;
          }
        }
        result[date] = sensoresMap;
      }
    }
    return result;
  }

  /// Busca o valor mais recente de cada sensor para o dia informado
  Future<Map<String, double>> getLatestSensorValues(String estufaId, String date) async {
    final snapshot = await _db.child('$estufaId/$date').get();
    if (!snapshot.exists) return {};
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final Map<String, double> result = {};
    for (final sensor in ['temp', 'hum', 'moist', 'lum']) {
      if (data[sensor] is Map) {
        final horarios = Map<String, dynamic>.from(data[sensor]);
        if (horarios.isNotEmpty) {
          final latestKey = horarios.keys.toList()..sort();
          final lastHorario = latestKey.last;
          final value = horarios[lastHorario];
          result[sensor] = (value is num) ? value.toDouble() : double.tryParse(value.toString()) ?? 0.0;
        } else {
          result[sensor] = 0.0;
        }
      } else {
        result[sensor] = 0.0;
      }
    }
    return result;
  }

  Future<String?> getEstufaName(String estufaId) async {
    final snapshot = await _db.child('$estufaId/name').get();
    if (snapshot.exists) {
      return snapshot.value as String;
    }
    return null;
  }

  Future<bool> checkPassword(String estufaId, String password) async {
    final snapshot = await _db.child('$estufaId/password').get();
    if (snapshot.exists && snapshot.value == password) {
      return true;
    }
    return false;
  }
}
