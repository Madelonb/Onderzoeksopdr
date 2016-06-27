//#include <LiquidCrystal.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// Data wire is plugged into pin 2 on the Arduino
#define ONE_WIRE_BUS 7
const int sensorPin = A1;
int pulsePin = 0;                 // Pulse Sensor purple wire connected to analog pin 0
int blinkPin = 13;                // pin to blink led at each beat
int fadePin = 5;                  // pin to do fancy classy fading blink at each beat
int fadeRate = 0;                 // used to fade LED on with PWM on fadePin

// Setup a oneWire instance to communicate with any OneWire devices (not just Maxim/Dallas temperature ICs)
OneWire oneWire(ONE_WIRE_BUS);

// Pass our oneWire reference to Dallas Temperature.
DallasTemperature sensors(&oneWire);
int force;
volatile int BPM;                   // int that holds raw Analog in 0. updated every 2mS
volatile int Signal;                // holds the incoming raw data
volatile int IBI = 600;             // int that holds the time interval between beats! Must be seeded!
volatile boolean Pulse = false;     // "True" when User's live heartbeat is detected. "False" when not a "live beat".
volatile boolean QS = false;        // becomes true when Arduoino finds a beat.


void setup() {

  sensors.begin(); // Start up the sensor library
  pinMode(blinkPin, OUTPUT);        // pin that will blink to your heartbeat!
  pinMode(fadePin, OUTPUT);         // pin that will fade to your heartbeat!
  Serial.begin(115200);             // we agree to talk fast!
  //Serial.begin(9600); // Start the serial communication at 9600 kbs/s
  interruptSetup();                 // sets up to read Pulse Sensor signal every 2mS
}

void loop() {

  force = analogRead(sensorPin);
  sensors.requestTemperatures(); // Send the command to get temperatures


  Serial.print(sensors.getTempCByIndex(0), DEC);
  Serial.print(",");
  //Serial.println();
  if (QS == true){
  Serial.print(force);
  } else {
  Serial.println(force);
  }



  if (QS == true) {    // A Heartbeat Was Found
    // BPM and IBI have been Determined
    // Quantified Self "QS" true when arduino finds a heartbeat
    fadeRate = 255;         // Makes the LED Fade Effect Happen
    // Set 'fadeRate' Variable to 255 to fade LED with pulse
    serialOutputWhenBeatHappens();   // A Beat Happened, Output that to serial.
    QS = false;                      // reset the Quantified Self flag for next time
  }

  //ledFadeToBeat();                      // Makes the LED Fade Effect Happen


  delay(10);

}
//
//void ledFadeToBeat(){
//    fadeRate -= 15;                         //  set LED fade value
//    fadeRate = constrain(fadeRate,0,255);   //  keep LED fade value from going into negative numbers!
//    analogWrite(fadePin,fadeRate);          //  fade LED
//  }








