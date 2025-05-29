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
  connectWiFi();
  blueLed(true);

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);

  Serial.println();
  Serial.print(Firebase.getString("/Estufa\ 01/name"));
  Serial.println();
  blueLed(false);
}


void loop(){




}