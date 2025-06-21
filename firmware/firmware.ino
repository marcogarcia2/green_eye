#include <WiFi.h>
#include <IOXhop_FirebaseESP32.h>
#include <ArduinoJson.h>

#include "sensors.h"
#include "comm.h"

#define SLEEP_INTERVAL 900 // 15 minutos em segundos

// Variável global que irá armazenar o tempo
tm timeinfo;

// ===================================================================
// --- FUNÇÃO PRIMORDIAL:
// Coleta os dados referentes à amostra atual.
SensorData collectData(){

  // Devemos preencher os dados de sample
  SensorData sample;

  // Conecta-se à internet
  if (!connectWiFi()) {
    Serial.println("Erro ao obter conexão WiFi.");
    restartSystem();
  }
  
  // Descobre informações sobre data e hora
  configTime(-3 * 3600, 0, "pool.ntp.org"); // Configura NTP com fuso horário de Brasília (-3 horas)
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter horário.");
    restartSystem();
  }
  
  Serial.println("Iniciando a coleta dos dados...");
  
  // Calculando o horário atual e salvando em data.time, para formar a chave do BD
  int hh = timeinfo.tm_hour;
  int mm = timeinfo.tm_min;
  while (mm % (SLEEP_INTERVAL / 60) != 0) mm--;
  snprintf(sample.time, 6, "%02d:%02d", hh, mm); // Forma a chave no formato HH:MM

  // Descobrindo a data atual, salva em sample.date para formar a chave do BD
  strcpy(sample.date, getDate()); // Forma a chave no formato YYYY-MM-DD

  // Lê os dados do ambiente das estufas através dos sensores
  readSensors(&sample);

  return sample;
}
// =================================================================== //

// Fluxo principal de execução
void setup(){

  Serial.begin(9600);

  // Coleta os dados dos sensores e armazena na struct SensorData, referente à amostra atual
  Serial.println("\nESP32 ligada!");
  initSensors();
  SensorData sample = collectData();
  printData(sample);

  // Depois de coletados, vamos inserir os dados no BD
  insertData(sample);

  // É necessário saber que horas são para calcular quanto ela deve dormir.
    if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter horário. Reiniciando o sistema...");
    restartSystem();
  }

  // Hora do dia em segundos
  int current_time = timeinfo.tm_hour * 3600 + timeinfo.tm_min * 60 + timeinfo.tm_sec;
  
  int target_time = ((current_time / SLEEP_INTERVAL) + 1) * SLEEP_INTERVAL; // Calcula o próximo horário de funcionamento
  int calculated_sleep_time = target_time - current_time; // Cálculo da quantidade de segundos que a ESP deve dormir

  // Faz a ESP dormir até o próximo horário de operação
  deepSleep(calculated_sleep_time);
}


void loop(){
  // Usado para debug
  //  new_data = readSensors();
  //  printData(new_data);
  //  delay(5000);
}
