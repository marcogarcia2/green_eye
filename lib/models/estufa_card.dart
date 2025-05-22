class EstufaCard {
  final String id;
  final String nome;
  final Map<String, double> sensores;
  final Map<String, List<double>> historico;
  final Map<String, Map<String, double>> alertas;

  const EstufaCard({
    required this.id,
    required this.nome,
    required this.sensores,
    this.historico = const {},
    this.alertas = const {},
  });

  EstufaCard copyWith({
    String? id,
    String? nome,
    Map<String, double>? sensores,
    Map<String, List<double>>? historico,
    Map<String, Map<String, double>>? alertas,
  }) => EstufaCard(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        sensores: sensores ?? this.sensores,
        historico: historico ?? this.historico,
        alertas: alertas ?? this.alertas,
      );
}
