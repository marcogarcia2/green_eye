#include <WiFi.h>
#include <IOXhop_FirebaseESP32.h>
#include <ArduinoJson.h>

#include "secret.h"

// Função que liga ou desliga o LED Azul
void blueLED(bool status){
  pinMode(2, OUTPUT);
  if (status) digitalWrite(2, HIGH);
  else digitalWrite(2, LOW);
}

void setup(){

  Serial.begin(115200);

  blueLED(true);
  // Ler dados dos sensores
  //

  // Escrever os dados:
  connectWiFi();
  /// Descobrir que dia é hoje
  /// Descobrir que horas são (hora que começou) (talvez usar variavel estatica)


  // Conectar com o banco de dados
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  
  // Escrever dados
  /// Criar função que escreve cada tipo de dado no dia e horário atual
  blueLED(false);
  
  // Calcular quanto deve-se dormir
  /// Baseado no horário atual (Exato)
  //deepSleep(tempo);

}


void loop(){




}
