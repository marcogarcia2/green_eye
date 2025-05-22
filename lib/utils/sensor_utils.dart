import 'package:flutter/material.dart';

class SensorUtils {
  static String getUnidade(String sensorKey) {
    switch (sensorKey) {
      case 'Temperatura':
        return '°C';
      case 'Umidade do Ar':
      case 'Umidade do Solo':
        return '%';
      default:
        return '';
    }
  }

  static double getMinValue(String sensorKey) {
    if (sensorKey == 'Temperatura') return -10.0;
    return 0.0;
  }

  static double getMaxValue(String sensorKey) {
    if (sensorKey == 'Temperatura') return 50.0;
    return 100.0;
  }

  static IconData getIconData(String sensorKey) {
    switch (sensorKey) {
      case 'Temperatura':
        return Icons.thermostat;
      case 'Umidade do Ar':
        return Icons.water_drop;
      case 'Umidade do Solo':
        return Icons.grass;
      default:
        return Icons.sensors;
    }
  }
}
