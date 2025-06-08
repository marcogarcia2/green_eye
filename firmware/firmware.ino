#include <WiFi.h>
#include <IOXhop_FirebaseESP32.h>
#include <ArduinoJson.h>

#include "sensors.h"
#include "secret.h"

#define NUM_SENSORS 4
#define SLEEP_INTERVAL 15 * 60 * 1000000 // 15 minutos escritos em microssegundos

// Variável global que irá armazenar o tempo
tm timeinfo;

void setup(){

  Serial.begin(9600);

  // Coleta os dados dos sensores e armazena na struct "data"
  initSensors();
  SensorData data = readSensors();
  printData(data);

  // Conecta-se à internet para poder escrever os dados
  connectWiFi();
  configTime(-3 * 3600, 0, "pool.ntp.org"); // Configura NTP com fuso horário de Brasília (-3 horas)
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter horário. Reiniciando o sistema...");
    // restartSystem();
    ESP.restart();
  }

  // Sinaliza que se conectou à internet
  blueLED(true);

  // Calculando o horário atual (para formar a chave do item no BD)
  char timeBuffer[10];
  int hh = timeinfo.tm_hour;
  int mm = timeinfo.tm_min;
  while (mm % 15 != 0) mm--;

  // Forma a chave no formato HH:MM
  char timeBuffer[6];
  snprintf(timeBuffer, 6, "%02d:%02d", hh, mm);

  // Descobrir que dia é hoje
  char dateBuffer[11];
  strcpy(dateBuffer, getDate());

  // Agora é preciso começar a construir os paths de cada dado
  char path[70];                  // path em que o item será guardado
  char base_path[70] = "/";       // path base, constante em cada iteração
  strcat(base_path, ESTUFA_ID);
  strcat(base_path, "/");
  strcat(base_path, dateBuffer);
  strcat(base_path, "/");
  // Serial.println(base_path);


  // Conectar com o banco de dados
  reconnectWifi();  // garante conexão com a internet
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  // Loop de escrita das amostras coletadas
  for (int i = 0; i < NUM_SENSORS; i++){
    
    // Reinicia o path com o base_path
    strcpy(path, base_path);
    
    // Insere os dados coletados no BD, corrigindo o path
    switch(i){
      case 0: 
        strcat(path, "hum/");
        strcat(path, timeBuffer);
        Firebase.setFloat(path, data.humidity);
        break;
      
      case 1:
        strcat(path, "lum/");
        strcat(path, timeBuffer);
        Firebase.setInt(path, data.luminosity);
        break;

      case 2:
        strcat(path, "moist/");
        strcat(path, timeBuffer);
        Firebase.setInt(path, data.soilMoisture);
        break;

      case 3:
        strcat(path, "temp/");
        strcat(path, timeBuffer);
        Firebase.setFloat(path, data.temperature);
        break;
      
      case default: 
        break;
    }

  }

  // É necessário saber que horas são para calcular quanto ela deve dormir. 
    if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter horário. Reiniciando o sistema...");
    // restartSystem();
    ESP.restart();
  }

  // Hora do dia em segundos
  int current_time = timeinfo.tm_hour * 3600 + timeinfo.tm_min * 60 + timeinfo.tm_sec;
  
  // Horário até qual deve dormir
  int target_time = 0;
  while (target_time < current_time){
    target_time += 900; // (900 = 15*60) de 15 em 15 minutos
  }

  // Cálculo da quantidade de segundos que a ESP deve dormir
  int calculated_sleep_time = target_time - current_time;

  // Desliga o LED e garante os prints seriais
  blueLED(false);
  Serial.flush();

  // Faz a ESP dormir até o próximo horário de operação
  deepSleep(calculated_sleep_time);
}


void loop(){
  // Usado para debug
  SensorData new_data = readSensors();
  printData(new_data);
  delay(1000);
}
