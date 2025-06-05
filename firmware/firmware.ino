#include <WiFi.h>
#include <IOXhop_FirebaseESP32.h>
#include <ArduinoJson.h>

#include "functions.h"
#include "secret.h"

// Função que liga ou desliga o LED Azul
void blueLED(bool status){
  pinMode(2, OUTPUT);
  if (status) digitalWrite(2, HIGH);
  else digitalWrite(2, LOW);
}

void setup(){

  Serial.begin(9600);
  initSensors();


}


void loop(){


  SensorData data = readSensors();
  
  Serial.print("Temperature = ");
  Serial.println(data.temperature);
  Serial.print("Humidity = ");
  Serial.println(data.humidity);
  Serial.print("Luminosity = ");
  Serial.println(data.luminosity);
  Serial.print("Soil Moisture = ");
  Serial.println(data.soilMoisture);

  // Escrever os dados:
  connectWiFi();

  configTime(-3 * 3600, 0, "pool.ntp.org"); // Configura NTP com fuso horário de Brasília (-3 horas)

  if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter horário. Reiniciando o sistema...");
    // deepSleep(5); // Dorme por 10 segundos para tentar novamente
  }

  // Descobrindo o horário atual
  int currentTime = timeinfo.tm_hour * 3600 + timeinfo.tm_min * 60; // + timeinfo.tm_sec;
  char timeBuffer[10] = strcpy(getTimeString(curentTime));

  /// Descobrir que dia é hoje
  char dateBuffer[15];
  strcpy(dateBuffer, getDate());

  /// Descobrir que horas são (hora que começou) (talvez usar variavel estatica) 
  
  blueLED(true);
  // Conectar com o banco de dados
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  Estufa_id + dia de hoje + tipo + horario = dado
  char base_path[70] = "/";
  strcat(base_path, ESTUFA_ID);
  strcat(base_path, "/");
  strcat(base_path, dateBuffer);
  strcat(base_path, "/");

  char path[70];
  Serial.println(base_path);

  for (int i = 0; i < 4; i++){
    strcpy(path, base_path);
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
    }

  }


  Serial.println(Firebase.getString("/Estufa_teste/name"));
  Serial.println(Firebase.getFloat("/Estufa_teste/2025-05-29/temp/14:00"));
  Serial.println(Firebase.getFloat("/Estufa_teste/2025-05-29/hum/14:00"));
  Serial.println(Firebase.getInt("/Estufa_teste/2025-05-29/lum/14:00"));
  Serial.println(Firebase.getInt("/Estufa_teste/2025-05-29/moist/14:00"));
  

  
  
  /// Criar função que escreve cada tipo de dado no dia e horário atual
  blueLED(false);
  
  // Calcular quanto deve-se dormir
  /// Baseado no horário atual (Exato)
  //deepSleep(tempo);
  delay(1000);

}
