/*
    A sketch that reads the temperature from a Dallas
    DS18B20 temperature sensor and shows it on a 4x20 LCD
    display. It also sends the value from the sensor true
    the serial line from the Arduino.
    LCD for Arduino 0021 or higer
    Cpyright (C) 2010  P.Olsson (patrik.olsson@x-firm.com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

//#include <LiquidCrystal.h>
#include <OneWire.h>
#include <DallasTemperature.h>
 
// Data wire is plugged into pin 2 on the Arduino
#define ONE_WIRE_BUS 7
const int sensorPin = A1;
 
// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);
 
// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);
int force;


void setup() {
  
  sensors.begin(); // Start up the sensor library  
  Serial.begin(9600); // Start the serial communication at 9600 kbs/s
}

void loop() {
  
  force = analogRead(sensorPin);
  sensors.requestTemperatures(); // Send the command to get temperatures


  Serial.print(sensors.getTempCByIndex(0), DEC);
  Serial.print(",");
  //Serial.println();
  Serial.println(force);
  //Serial.print(",");


  delay(20);
  
}








