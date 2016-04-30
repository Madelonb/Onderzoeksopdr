//#include <LiquidCrystal.h>
#include <OneWire.h>
#include <DallasTemperature.h>
 
// Data wire is plugged into pin 2 on the Arduino
#define ONE_WIRE_BUS 7
const int ledPin = 6;     //pin 3 has PWM funtion
const int sensorPin = A1; //pin A1 to read analog input

//Variables:
int force; //save analog value
 
// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);
 
// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);


void setup() {
  
  pinMode(ledPin, OUTPUT);  //Set pin 3 as 'output' 
  //sensors.begin(); // Start up the sensor library  
  Serial.begin(9600); // Start the serial communication at 9600 kbs/s

}

void loop() {
  
  force = analogRead(sensorPin)/4;       //Read and save analog value from potentiometer
  Serial.write(force);               //Print value
  force = map(force, 0, 1023, 0, 255); //Map value 0-1023 to 0-255 (PWM)
  analogWrite(ledPin, force);          //Send PWM value to led
  delay(100); 
  
  printSerialTemp();
  
}

void printSerialTemp(){
  sensors.requestTemperatures(); // Send the command to get temperatures
  Serial.println(sensors.getTempCByIndex(0), DEC);
}


