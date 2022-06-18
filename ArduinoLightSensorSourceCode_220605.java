int analogValue;

void setup() {
  // put your setup code here, to run once:
   Serial.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:
   analogValue = analogRead(A0);
   Serial.print(analogValue);
   Serial.print('a');
   delay(20);
}
