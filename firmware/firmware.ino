#include <WiFi.h>
#include <IOXhop_FirebaseESP32.h>
#include <ArduinoJson.h>

#include "sensors.h"
#include "comm.h"

#define NUM_SENSORS 4
#define SLEEP_INTERVAL 900 // 15 minutos em segundos

// Variável global que irá armazenar o tempo
tm timeinfo;

void setup(){

  Serial.begin(9600);

  // Coleta os dados dos sensores e armazena na struct "data" de maneira offline
  Serial.println("\nESP32 ligada!\nIniciando a coleta de dados...");
  initSensors();
  SensorData data = readSensors();
  printData(data);

  // Conecta-se à internet para poder escrever os dados
  if (!connectWiFi()) {
    Serial.println("Erro ao obter conexão WiFi.");
    restartSystem();
  }

  configTime(-3 * 3600, 0, "pool.ntp.org"); // Configura NTP com fuso horário de Brasília (-3 horas)
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter horário.");
    restartSystem();
  }

  // Calculando o horário atual (para formar a chave do item no BD)
  int hh = timeinfo.tm_hour;
  int mm = timeinfo.tm_min;
  while (mm % (SLEEP_INTERVAL / 60) != 0) mm--;

  // Forma a chave no formato HH:MM
  char timeBuffer[6];
  snprintf(timeBuffer, 6, "%02d:%02d", hh, mm);
  Serial.print("Horário atual: ");
  Serial.println(timeBuffer);

  // Descobrir que dia é hoje
  char dateBuffer[11];
  strcpy(dateBuffer, getDate());
  Serial.print("Data atual: ");
  Serial.println(dateBuffer);

  // Agora é preciso começar a construir os paths de cada dado
  char path[70];                  // path em que o item será guardado
  char base_path[70] = "/";       // path base, constante em cada iteração
  strcat(base_path, ID_ESTUFA);
  strcat(base_path, "/");
  strcat(base_path, dateBuffer);
  strcat(base_path, "/");
  // Serial.println(base_path);

  // Garantindo conexão com a Internet antes de prosseguir
  if(!reconnectWiFi()){
    Serial.println("Erro ao obter conexão WiFi.");
    restartSystem();
  }
  
  // Conectar com o banco de dados
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Serial.println("Inserindo os dados no BD...");

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
        Firebase.setFloat(path, data.luminosity);
        break;

      case 2:
        strcat(path, "moist/");
        strcat(path, timeBuffer);
        Firebase.setFloat(path, data.soilMoisture);
        break;

      case 3:
        strcat(path, "temp/");
        strcat(path, timeBuffer);
        Firebase.setFloat(path, data.temperature);
        break;
      
      default: 
        break;
    }

  }

  Serial.println("Dados inseridos com sucesso.");

  // É necessário saber que horas são para calcular quanto ela deve dormir. 
    if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter horário. Reiniciando o sistema...");
    restartSystem();
  }

  // Hora do dia em segundos
  int current_time = timeinfo.tm_hour * 3600 + timeinfo.tm_min * 60 + timeinfo.tm_sec;
  
  // Calcula o próximo horário de funcionamento
  int target_time = ((current_time / SLEEP_INTERVAL) + 1) * SLEEP_INTERVAL;

  // Cálculo da quantidade de segundos que a ESP deve dormir
  int calculated_sleep_time = target_time - current_time;

  // Faz a ESP dormir até o próximo horário de operação
  deepSleep(calculated_sleep_time);
}


void loop(){
  // Usado para debug
  //  new_data = readSensors();
  //  printData(new_data);
  //  delay(5000);
}
