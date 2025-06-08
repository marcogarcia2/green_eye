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


// Função que liga ou desliga o LED Azul
void blueLED(bool status){
  pinMode(2, OUTPUT);
  if (status) digitalWrite(2, HIGH);
  else digitalWrite(2, LOW);
}

// === Function to Initialize Sensors ===
void initSensors() {
  blueLED(true);
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

// Função que exibe os dados coletados, um por linha
void printData(SensorData data){
  Serial.println("DADOS COLETADOS");
  Serial.println("===========================");
  Serial.print("Temperature = ");
  Serial.println(data.temperature);
  Serial.print("Humidity = ");
  Serial.println(data.humidity);
  Serial.print("Luminosity = ");
  Serial.println(data.luminosity);
  Serial.print("Soil Moisture = ");
  Serial.println(data.soilMoisture);
  Serial.println();
}

// Desligando os pinos antes de dormir
void turnOffSensors(){
  pinMode(LDR_PIN, INPUT);
  pinMode(DHT_PIN, INPUT);
  pinMode(SOIL_PIN, INPUT);
  blueLED(false);
}

// Função para colocar ESP32 em deep sleep por um tempo determinado
void deepSleep(int sleep_time){

  Serial.printf("Dormindo por %d segundos...\n\n\n", sleep_time);
  Serial.flush();
  turnOffSensors();

  esp_sleep_enable_timer_wakeup(sleep_time * 1000000LL);
  esp_deep_sleep_start();
  return;
}

//// Função que reinicia a ESP32
//void restartSystem(){
//  blueLED(false);
//  Serial.flush();
//  deepSleep(1);
//}

#endif
