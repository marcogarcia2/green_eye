import 'package:flutter/material.dart';

import '../models/estufa_card.dart';
import '../widgets/sensor_widgets.dart';
import '../firebase_realtime_service.dart';
import '../utils/sensor_utils.dart';
import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'package:fl_chart/fl_chart.dart';
import '../utils/estufa_storage.dart';


class EstufasPage extends StatefulWidget {
  const EstufasPage({super.key});
  @override
  State<EstufasPage> createState() => _EstufasPageState();
}

class _EstufasPageState extends State<EstufasPage> {
  final List<EstufaCard> estufas = [];
  final FirebaseRealtimeService _firebaseService = FirebaseRealtimeService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEstufasLocal();
  }

  Future<void> _loadEstufasLocal() async {
    setState(() { _isLoading = true; });
    final loaded = await EstufaStorage.loadEstufas();
    if (loaded.isNotEmpty) {
      // Para cada estufa, buscar apenas o valor mais recente do dia atual
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final List<Future<EstufaCard>> futurasEstufas = loaded.map((estufa) async {
        final latest = await _firebaseService.getLatestSensorValues(estufa.id, today);
        final sensores = {
          'Temperatura': latest['temp'] ?? 0.0,
          'Umidade do Ar': latest['hum'] ?? 0.0,
          'Umidade do Solo': latest['moist'] ?? 0.0,
          'Luminosidade': latest['lum'] ?? 0.0,
        };
        return estufa.copyWith(sensores: sensores);
      }).toList();
      final atualizadas = await Future.wait(futurasEstufas);
      setState(() {
        estufas.clear();
        estufas.addAll(atualizadas);
        _isLoading = false;
      });
    } else {
      setState(() {
        estufas.clear();
        _isLoading = false;
      });
      // Se não houver estufas salvas, pode carregar a padrão (opcional)
      // await _loadEstufaPadrao();
    }
  }

  Future<void> _saveEstufasLocal() async {
    await EstufaStorage.saveEstufas(estufas);
  }

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
            onPressed: () async {
              final estufaId = idController.text.trim();
              final senha = senhaController.text.trim();
              if (estufaId.isEmpty || senha.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, preencha todos os campos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              // Verifica se já existe uma estufa com esse ID
              final jaAdicionada = estufas.any((e) => e.id == estufaId);
              if (jaAdicionada) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Esta estufa já foi adicionada!'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              final isValid = await _firebaseService.checkPassword(estufaId, senha);
              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ID ou senha incorretos!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
              final latest = await _firebaseService.getLatestSensorValues(estufaId, today);
              final nome = await _firebaseService.getEstufaName(estufaId) ?? estufaId;
              setState(() {
                estufas.add(
                  EstufaCard(
                    id: estufaId,
                    nome: nome,
                    sensores: {
                      'Temperatura': latest['temp'] ?? 0.0,
                      'Umidade do Ar': latest['hum'] ?? 0.0,
                      'Umidade do Solo': latest['moist'] ?? 0.0,
                      'Luminosidade': latest['lum'] ?? 0.0,
                    },
                    historico: {
                      'Temperatura': [latest['temp'] ?? 0.0],
                      'Umidade do Ar': [latest['hum'] ?? 0.0],
                      'Umidade do Solo': [latest['moist'] ?? 0.0],
                      'Luminosidade': [latest['lum'] ?? 0.0],
                    },
                  ),
                );
              });
              await _saveEstufasLocal();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estufa adicionada com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
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
          children: [
            const Icon(Icons.eco, size: 28),
            const SizedBox(width: 8),
            const Text('GreenEye', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : estufas.isEmpty
                ? Center(
                    child: Text(
                      'Nenhuma estufa adicionada.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await _loadEstufasLocal();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: estufas.length,
                      itemBuilder: (context, index) {
                        final estufa = estufas[index];
                        return Dismissible(
                      key: Key(estufa.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: const Icon(Icons.delete_forever, color: Colors.red, size: 36),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            title: Column(
                              children: const [
                                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                                SizedBox(height: 12),
                                Text('Remover Estufa', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            content: Text(
                              'Tem certeza que deseja remover a estufa "${estufa.nome}"? Esta ação não pode ser desfeita.',
                              textAlign: TextAlign.center,
                            ),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                  textStyle: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text('Remover'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        final messenger = ScaffoldMessenger.of(context); // Salve antes do setState
                        setState(() {
                          estufas.removeAt(index);
                        });
                        await _saveEstufasLocal();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Estufa removida!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: InkWell(
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
                      ),
                    );
                  },
                ),
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

  Widget _buildMedicoesTab() {
    DateTime? _selectedDate;
    return StatefulBuilder(
      builder: (context, setState) {
        _selectedDate ??= DateTime.now();
        final String selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        return FutureBuilder<Map<String, Map<String, double>>>(
          future: FirebaseRealtimeService().getMedicoesDoDia(widget.estufa.id, selectedDateStr),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final sensoresMap = snapshot.data ?? {};
            final sensoresKeys = sensoresMap.keys.toList()..sort();
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: sensoresKeys.isEmpty ? 1 : sensoresKeys.length + 1,
                itemBuilder: (context, idx) {
                  if (idx == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Selecione o dia:', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade400,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate!,
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => _selectedDate = picked);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (sensoresKeys.isEmpty)
                          const Center(child: Text('Sem medições para este dia.', style: TextStyle(color: Colors.grey))),
                      ],
                    );
                  }
                  final sensorKey = sensoresKeys[idx - 1];
                  final horariosMap = sensoresMap[sensorKey] ?? {};
                  final horarios = horariosMap.keys.toList()..sort();
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        childrenPadding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
                        title: Row(
                          children: [
                            Icon(
                              SensorUtils.getIconData(_nomeSensorCompleto(sensorKey)),
                              color: Colors.green.shade400,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _nomeSensorCompleto(sensorKey),
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(0xFF424242)),
                            ),
                          ],
                        ),
                        children: horarios.isEmpty
                            ? [const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Sem medições para este sensor.', style: TextStyle(color: Colors.grey)),
                              )]
                            : List.generate(horarios.length, (i) {
                                final horario = horarios[i];
                                final valor = horariosMap[horario];
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  leading: Text(horario, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                  title: Text(
                                    valor == null
                                        ? 'Sem dados'
                                        : (valor == 0.0 ? 'Sem dados' : valor.toStringAsFixed(1) + _unidadeSensor(sensorKey)),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: (valor == null || valor == 0.0) ? Colors.grey : Colors.green[900],
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  String _nomeSensorCompleto(String key) {
    switch (key) {
      case 'temp':
        return 'Temperatura';
      case 'hum':
        return 'Umidade do Ar';
      case 'moist':
        return 'Umidade do Solo';
      case 'lum':
        return 'Luminosidade';
      default:
        return key;
    }
  }

  String _unidadeSensor(String key) {
    switch (key) {
      case 'temp':
        return '°C';
      case 'hum':
      case 'moist':
        return '%';
      case 'lum':
        return ' lx';
      default:
        return '';
    }
  }

  // _sensorMedicaoCompact removido pois não é mais utilizado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estufa.nome),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Medições'),
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
          _buildMedicoesTab(),
          _buildHistoricoTab(),
          _buildAlertasTab(),
        ],
      ),
    );
  }


  Widget _buildHistoricoTab() {
    DateTime? _selectedDate;
    return StatefulBuilder(
      builder: (context, setState) {
        _selectedDate ??= DateTime.now();
        final String selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
        return FutureBuilder<Map<String, Map<String, Map<String, double>>>> (
          future: FirebaseRealtimeService().getAllMedicoes(widget.estufa.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final medicoes = snapshot.data ?? {};
            final sensoresMap = medicoes[selectedDateStr] ?? {};
            final sensoresKeys = sensoresMap.keys.toList()..sort();
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {}); // Força rebuild, pode customizar para recarregar dados se necessário
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Selecione o dia:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate!,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _selectedDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (sensoresKeys.isEmpty)
                      const Center(child: Text('Sem medições para este dia.', style: TextStyle(color: Colors.grey)))
                    else ...sensoresKeys.map((sensorKey) {
                      final horariosMap = sensoresMap[sensorKey] ?? {};
                      final horarios = horariosMap.keys.toList()..sort();
                      final valores = horarios.map((h) => horariosMap[h] ?? 0.0).toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_nomeSensorCompleto(sensorKey), style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 240,
                              child: valores.isEmpty
                                  ? const Center(child: Text('Sem dados para exibir.', style: TextStyle(color: Colors.grey)))
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                      child: LineChart(
                                        LineChartData(
                                          gridData: FlGridData(
                                            show: true,
                                            drawVerticalLine: true,
                                            horizontalInterval: ((valores.reduce((a, b) => a > b ? a : b) - valores.reduce((a, b) => a < b ? a : b)) / 4).clamp(1, 100),
                                            verticalInterval: (valores.length / 4).ceilToDouble().clamp(1, 100),
                                            getDrawingHorizontalLine: (value) => FlLine(
                                              color: Colors.grey.withOpacity(0.15),
                                              strokeWidth: 1,
                                            ),
                                            getDrawingVerticalLine: (value) => FlLine(
                                              color: Colors.grey.withOpacity(0.10),
                                              strokeWidth: 1,
                                            ),
                                          ),
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 36,
                                                getTitlesWidget: (value, meta) {
                                                  if (valores.isEmpty) return const SizedBox.shrink();
                                                  final minY = valores.isEmpty ? 0.0 : (valores.reduce((a, b) => a < b ? a : b) - 2);
                                                  final maxY = valores.isEmpty ? 10.0 : (valores.reduce((a, b) => a > b ? a : b) + 2);
                                                  final midY = (minY + maxY) / 2;
                                                  if ((value - minY).abs() < 0.5 || (value - maxY).abs() < 0.5 || (value - midY).abs() < 0.5) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(right: 8.0),
                                                      child: Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10), textAlign: TextAlign.right),
                                                    );
                                                  }
                                                  return const SizedBox.shrink();
                                                },
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 36,
                                                getTitlesWidget: (value, meta) {
                                                  if (valores.isEmpty) return const SizedBox.shrink();
                                                  final minIdx = 0;
                                                  final maxIdx = valores.length - 1;
                                                  final midIdx = (valores.length / 2).floor();
                                                  final idx = value.toInt();
                                                  if (idx == minIdx || idx == maxIdx || idx == midIdx) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Transform.rotate(
                                                        angle: -0.7,
                                                        child: Text(horarios[idx], style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                                                      ),
                                                    );
                                                  }
                                                  return const SizedBox.shrink();
                                                },
                                                interval: 1,
                                              ),
                                            ),
                                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          ),
                                          borderData: FlBorderData(
                                            show: true,
                                            border: const Border(
                                              left: BorderSide(color: Colors.black12),
                                              bottom: BorderSide(color: Colors.black12),
                                              right: BorderSide(color: Colors.transparent),
                                              top: BorderSide(color: Colors.transparent),
                                            ),
                                          ),
                                          minY: valores.isEmpty ? 0 : (valores.reduce((a, b) => a < b ? a : b) - 2),
                                          maxY: valores.isEmpty ? 10 : (valores.reduce((a, b) => a > b ? a : b) + 2),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots: List.generate(
                                                valores.length,
                                                (i) => FlSpot(i.toDouble(), valores[i]),
                                              ),
                                              isCurved: true,
                                              color: Colors.green.shade700,
                                              barWidth: 2,
                                              belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.10)),
                                              dotData: FlDotData(
                                                show: true,
                                                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                                                  radius: 2.5,
                                                  color: Colors.green.shade800,
                                                  strokeWidth: 0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

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