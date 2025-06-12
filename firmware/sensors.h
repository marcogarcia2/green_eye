#ifndef SENSORS_H
#define SENSORS_H

#include <DHT.h>
#include <math.h>

// Definição dos Pinos
#define LDR_PIN     34
#define DHT_PIN     15
#define DHTTYPE     DHT22
#define SOIL_PIN    35

// Setup do sensor DHT
DHT dht(DHT_PIN, DHTTYPE);

// Estrutura que irá salvar os resultados
struct SensorData {
  float temperature;
  float humidity;
  float luminosity;
  int soilMoisture;
};

// Função que controla o LED Azul
void blueLED(bool status){
  pinMode(2, OUTPUT);
  if (status) digitalWrite(2, HIGH);
  else digitalWrite(2, LOW);
}

// Função que inicializa os sensores 
void initSensors() {
  blueLED(true);
  dht.begin();
}

// Convert 
double convertLuminosity(float lumADC){


  double voltage = (lumADC / 4095.0 ) * 3.3;
  if (voltage >= 3.29) voltage = 3.29;
  if (voltage <= 0.01) voltage = 0.01;  // Evitar zero ou negativo


  double resistance = (double)voltage*1000000.0 / (3.3 - voltage);

  double lum = pow(10, 6.5-1.25*log10(resistance));
  // debug
  // Serial.print("Valor ADC: ");
  // Serial.println(lumADC);
  // Serial.print("Tensão consumida: ");
  // Serial.println(voltage);
  // Serial.print("Resistência: ");
  // Serial.println(resistance);
  // Serial.print("Luminosidade: ");
  // Serial.println(lum);

  return lum;
}


// Função que lê os dados dos sensores
SensorData readSensors(int samples = 15) {
  
  // Uma para cada tipo de dado
  float totalHumidity = 0;
  float totalTemp = 0;
  int totalLDR = 0;
  int totalSoil = 0;

  // Realiza várias leituras dos dados
  for (int i = 0; i < samples; i++) {
    totalHumidity += dht.readHumidity();
    totalTemp += dht.readTemperature();
    totalLDR += analogRead(LDR_PIN);
    totalSoil += analogRead(SOIL_PIN);
    delay(500);  // Delay entre medições para evitar instabilidades
    yield();
  }

  // Salva os dados coletados, tirando a média
  SensorData data;
  
  data.humidity = totalHumidity / samples;
  data.temperature = totalTemp / samples;
  data.luminosity = convertLuminosity((float)totalLDR/samples);
  data.soilMoisture = totalSoil / samples;

  return data;
}

// Função que exibe os dados coletados, um por linha
void printData(SensorData data){
  Serial.println("=====================");
  Serial.println("   DADOS COLETADOS   ");
  Serial.println("=====================");
  
  // Temperatura
  Serial.print("Temperatura: ");
  Serial.print(data.temperature);
  Serial.println(" ºC");

  // Umidade do ar
  Serial.print("Umidade do ar: ");
  Serial.print(data.humidity);
  Serial.println("%");

  // Luminosidade
  Serial.print("Luminosidade: ");
  Serial.print(data.luminosity);
  Serial.println(" lux");

  // Umidade do Solo
  Serial.print("Umidade do Solo: ");
  Serial.print(data.soilMoisture);
  Serial.println("%");

  Serial.println();
  Serial.flush();
}

// Desligando os pinos antes de dormir
void turnOffSensors(){
  pinMode(LDR_PIN, INPUT);
  pinMode(DHT_PIN, INPUT);
  pinMode(SOIL_PIN, INPUT);
  blueLED(false);
}

// Função que reinicializa o circuito todo
void restartSystem(){
  turnOffSensors();
  Serial.println("Reiniciando o sistema...");
  Serial.flush();
  ESP.restart();
}

// Função para colocar ESP32 em deep sleep por um tempo determinado
void deepSleep(int sleep_time){

  Serial.printf("Dormindo por %d segundos até a próxima medição...\n\n\n", sleep_time);
  Serial.flush();
  turnOffSensors();

  esp_sleep_enable_timer_wakeup(sleep_time * 1000000LL);
  esp_deep_sleep_start();
  return;
}

#endif
