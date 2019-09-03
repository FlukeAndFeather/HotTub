#include <Arduino.h>

#define SUBTEMP_PIN 4

void setup() {
  // Connect to Serial
  Serial.begin(9600);
  while(!Serial);

  pinMode(SUBTEMP_PIN, INPUT);
}

void loop() {
  // Read temperature
  int16_t subtemp_raw = analogRead(SUBTEMP_PIN);

  // Convert to degC
  int16_t mask = 0x07FF;
  float subtemp_degC = (subtemp_raw & mask) / 16.0;

  // Print raw and converted values
  Serial.println(subtemp_degC, 4);
  delay(1000);
}