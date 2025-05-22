import 'package:flutter/material.dart';
import '../models/estufa_card.dart';
import '../widgets/sensor_widgets.dart';


class EstufasPage extends StatefulWidget {
  const EstufasPage({super.key});
  @override
  State<EstufasPage> createState() => _EstufasPageState();
}

class _EstufasPageState extends State<EstufasPage> {
  final List<EstufaCard> estufas = [
    const EstufaCard(
      id: '001',
      nome: 'Estufa 1',
      sensores: {
        'Temperatura': 25.5,
        'Umidade do Ar': 65.0,
        'Umidade do Solo': 80.0,
        'Luminosidade': 500,
      },
      historico: {
        'Temperatura': [24.0, 24.5, 25.0, 25.5],
        'Umidade do Ar': [63.0, 64.0, 64.5, 65.0],
        'Umidade do Solo': [78.0, 79.0, 79.5, 80.0],
        'Luminosidade': [100, 89, 70, 65],
      },
    ),
    const EstufaCard(
      id: '002',
      nome: 'Estufa 2',
      sensores: {'Temperatura': 23.8, 'Umidade do Ar': 70.0},
      historico: {
        'Temperatura': [23.0, 23.2, 23.5, 23.8],
        'Umidade do Ar': [68.0, 68.5, 69.0, 70.0],
      },
    ),
  ];

  void _showAddEstufaDialog() {
    final idController = TextEditingController();
    final senhaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Estufa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'ID da Estufa',
                hintText: 'Digite o ID da estufa',
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: senhaController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                hintText: 'Digite a senha da estufa',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (idController.text.isNotEmpty && senhaController.text.isNotEmpty) {
                setState(() {
                  estufas.add(
                    EstufaCard(
                      id: idController.text,
                      nome: 'Estufa ${estufas.length + 1}',
                      sensores: {'Temperatura': 0.0, 'Umidade do Ar': 0.0},
                      historico: {
                        'Temperatura': [0.0],
                        'Umidade do Ar': [0.0],
                      },
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Estufa adicionada com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, preencha todos os campos'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.eco, size: 28),
            SizedBox(width: 8),
            Text('GreenEye', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEstufaDialog,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: estufas.length,
          itemBuilder: (context, index) {
            final estufa = estufas[index];
            return InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EstufaDetalhesPage(estufa: estufa)),
              ),
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(estufa.nome, style: Theme.of(context).textTheme.titleLarge),
                          Text('ID: ${estufa.id}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                        ],
                      ),
                      const Divider(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: estufa.sensores.entries.map((sensor) => SensorDisplay(sensor: sensor)).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class EstufaDetalhesPage extends StatefulWidget {
  final EstufaCard estufa;
  const EstufaDetalhesPage({super.key, required this.estufa});
  @override
  State<EstufaDetalhesPage> createState() => _EstufaDetalhesPageState();
}

class _EstufaDetalhesPageState extends State<EstufaDetalhesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, Map<String, double>> alertas = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    for (final sensor in widget.estufa.sensores.keys) {
      alertas[sensor] = {
        'min': widget.estufa.alertas[sensor]?['min'] ?? (sensor == 'Temperatura' ? 18.0 : 50.0),
        'max': widget.estufa.alertas[sensor]?['max'] ?? (sensor == 'Temperatura' ? 30.0 : 80.0),
      };
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estufa.nome),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Atual'),
            Tab(text: 'Histórico'),
            Tab(text: 'Alertas'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          indicatorColor: Colors.green,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAtualTab(),
          _buildHistoricoTab(),
          _buildAlertasTab(),
        ],
      ),
    );
  }

  Widget _buildAtualTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.estufa.sensores.entries
              .map((sensor) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SensorDisplay(sensor: sensor),
                  ))
              .toList(),
        ),
      );

  Widget _buildHistoricoTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.estufa.historico.entries.map((entry) {
            final sensorKey = entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sensorKey, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Text('Aqui virá o gráfico de $sensorKey', style: const TextStyle(color: Colors.grey)),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );

  Widget _buildAlertasTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.estufa.sensores.keys.expand((sensorKey) => [
            Text(sensorKey, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AlertaSlider(
              sensorKey: sensorKey,
              tipoAlerta: 'min',
              label: 'Mínimo',
              value: alertas[sensorKey]!['min']!,
              onChanged: (value) => setState(() => alertas[sensorKey]!['min'] = value),
            ),
            AlertaSlider(
              sensorKey: sensorKey,
              tipoAlerta: 'max',
              label: 'Máximo',
              value: alertas[sensorKey]!['max']!,
              onChanged: (value) => setState(() => alertas[sensorKey]!['max'] = value),
            ),
            const SizedBox(height: 24),
          ]).toList(),
        ),
      );
}
