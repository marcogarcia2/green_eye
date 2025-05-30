#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include <DHT.h>

// === Pin Definitions ===
#define LDR_PIN     34
#define DHT_PIN     15
#define DHTTYPE     DHT22
#define SOIL_PIN    35

// === Sensor Setup ===
DHT dht(DHT_PIN, DHTTYPE);

// === Struct to Store Results ===
struct SensorData {
  float temperature;
  float humidity;
  int luminosity;
  int soilMoisture;
};

// === Function to Initialize Sensors ===
void initSensors() {
  dht.begin();
}

// === Function to Read and Average Data ===
SensorData readSensors(int samples = 10) {
  float totalHumidity = 0;
  float totalTemp = 0;
  long totalLDR = 0;
  long totalSoil = 0;

  for (int i = 0; i < samples; i++) {
    totalHumidity += dht.readHumidity();
    totalTemp += dht.readTemperature();
    totalLDR += analogRead(LDR_PIN);
    totalSoil += analogRead(SOIL_PIN);
    delay(500);  // Allow sensors to stabilize between reads
  }

  SensorData data;
  data.humidity = totalHumidity / samples;
  data.temperature = totalTemp / samples;
  data.luminosity = totalLDR / samples;
  data.soilMoisture = totalSoil / samples;

  return data;
}

#endif
