import 'package:flutter/material.dart';
import '../utils/sensor_utils.dart';


class SensorDisplay extends StatelessWidget {
  final MapEntry<String, double> sensor;
  const SensorDisplay({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    final icon = SensorUtils.getIconData(sensor.key);
    final unidade = SensorUtils.getUnidade(sensor.key);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[100],
        border: Border.all(color: Colors.green[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sensor.key, style: const TextStyle(fontSize: 12, color: Color(0xFF424242))),
              Text(
                '${sensor.value}$unidade',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AlertaSlider extends StatelessWidget {
  final String sensorKey;
  final String tipoAlerta;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const AlertaSlider({
    super.key,
    required this.sensorKey,
    required this.tipoAlerta,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final min = SensorUtils.getMinValue(sensorKey);
    final max = SensorUtils.getMaxValue(sensorKey);
    final unidade = SensorUtils.getUnidade(sensorKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}$unidade', style: Theme.of(context).textTheme.bodyLarge),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).toInt(),
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
