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
  /// Descobrir que dia é hoje
  /// Descobrir que horas são (hora que começou) (talvez usar variavel estatica)

  blueLED(true);
  // Conectar com o banco de dados
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Serial.println(Firebase.getString("/Estufa_teste/name"));
  Serial.println(Firebase.getFloat("/Estufa_teste/2025-05-29/temp/14:00"));
  Serial.println(Firebase.getFloat("/Estufa_teste/2025-05-29/hum/14:00"));
  Serial.println(Firebase.getInt("/Estufa_teste/2025-05-29/lum/14:00"));
  Serial.println(Firebase.getInt("/Estufa_teste/2025-05-29/moist/14:00"));
  // Escrever dados
  Firebase.setFloat("/Estufa_teste/2025-05-29/temp/14:00", data.temperature);
  Firebase.setFloat("/Estufa_teste/2025-05-29/hum/14:00", data.humidity);
  Firebase.setInt("/Estufa_teste/2025-05-29/lum/14:00", data.luminosity);
  Firebase.setInt("/Estufa_teste/2025-05-29/moist/14:00", data.soilMoisture);

  
  
  /// Criar função que escreve cada tipo de dado no dia e horário atual
  blueLED(false);
  
  // Calcular quanto deve-se dormir
  /// Baseado no horário atual (Exato)
  //deepSleep(tempo);
  delay(1000);

}
