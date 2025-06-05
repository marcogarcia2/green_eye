#include <WiFi.h>
#include <IOXhop_FirebaseESP32.h>
#include <ArduinoJson.h>
#include <time.h>
#include <string.h>

#include "secret.h"


#define MAX_ATTEMPTS 3

// Função que conecta-se ao wifi
bool connectWiFi() {

  // Três tentativas no total, caso falhe, rebootar e tentar de novo
  for (int attempts = 0; attempts < MAX_ATTEMPTS; attempts++){

    // Conexão em WiFi tradicional
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    // Conexão no eduroam
    // WiFi.begin(WIFI_PASSWORD, WPA2_AUTH_PEAP, EAP_IDENTITY, EAP_USERNAME, EAP_PASSWORD); // Para redes como eduroam
    
    Serial.print("Conectando ao WiFi");
    
    int i = 0; // Contador de tentativas
    while (WiFi.status() != WL_CONNECTED && i < 30) { // 100 segundos de tentativa, aproximadamente
      delay(1000);
      Serial.print(".");
      i++;
    }
    
    // Se a conexão for realizada com sucesso:
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println("\nWiFi conectado!");
      Serial.print("IP: ");
      Serial.println(WiFi.localIP());
      return true;
    } 

    // Se não, dá mais chances ou reseta o sistema (else)

    WiFi.disconnect();
    
    switch(attempts){
      case 0: 
        Serial.println("\nERRO: A primeira tentativa de conexão falhou.");
        break;

      case 1:
        Serial.println("\nERRO: A segunda tentativa de conexão também falhou.");
        break;
      
      case 2:
        Serial.println("\nERRO: A última tentativa de conexaão também falhou. Vamos tentar novamente...");
        break;

      default:
        break;
    } 
  }
  
  return false;
}

// Função que obtém a data de hoje no formato "YYYY-MM-DD"
char* getDate() {
  struct tm timeinfo;

  // Atualiza as informações de tempo local
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Erro ao obter o horário local!");
    return nullptr; // Retorna null em caso de erro
  }

  // Aloca memória para armazenar a data
  static char date[11]; // "YYYY-MM-DD" + null terminator

  // Formata a data como "YYYY-MM-DD"
  snprintf(date, sizeof(date), "%04d-%02d-%02d", 
           timeinfo.tm_year + 1900, // Ano desde 1900
           timeinfo.tm_mon + 1,     // Mês (0 a 11, por isso adicionamos 1)
           timeinfo.tm_mday);       // Dia do mês

  return date; // Retorna o ponteiro para a string formatada
}

// Função que tenta se reconectar ao wifi, somente caso esse tenha caído.
void reconnectWiFi(){
  if(WiFi.status() != WL_CONNECTED){
    while(!connectWiFi());
  }
}
