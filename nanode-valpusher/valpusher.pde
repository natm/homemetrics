#include <OneWire.h>
#include <EtherCard.h>
#include <SoftwareSerial.h>

#include <avr/wdt.h>

#define DS18S20      0x10
#define DS18B20      0x28
#define DS2405       0x05
#define pinLEDpwr    6

Stash stash;
static uint32_t timer;
byte Ethernet::buffer[700];

char website[] PROGMEM = "valstore.nuqe.net";
static byte mymac[] = {  0x74,0x69,0x69,0x2D,0x30,0x31 }; // live
//static byte mymac[] = {  0x74,0x69,0x69,0x2D,0x30,0x29 }; // dev
// feeder on 0x28

char devicename[] = "collector1";

int owpins[7] = {14,15,16,17,18,19,3};
OneWire ow[7] = {  OneWire(owpins[0]), OneWire(owpins[1]), OneWire(owpins[2]),OneWire(owpins[3]),OneWire(owpins[4]),OneWire(owpins[5]),OneWire(owpins[6]) };
int buses = 7;
int HighByte, LowByte, TReading, SignBit, Tc_100;
bool tsensor;
bool addressable;
int a,b;

SoftwareSerial mySerial = SoftwareSerial(4, 300);
byte readByte = 0xFF;
byte pinState = 0;
char startPattern[] = "<ch1><watts>";
char endPattern[] = "<";
int state = 0;
int pos = 0;
int power = 0;
int powerLast = 0;

long minsup = 0;
long polled = 0;

float temp;
byte sd;

void setup() {
  Serial.begin(19200);
  Serial.println("");
  Serial.println("");

  // flash LED
  pinMode(pinLEDpwr, OUTPUT);
  for(int b=0;b<4; b++)
  {
    digitalWrite(pinLEDpwr, HIGH);
    delay(100);
    digitalWrite(pinLEDpwr, LOW);
    delay(100);
  }

  pinMode(4, INPUT);
  mySerial.begin(9650);

  setupNetwork();
  digitalWrite(pinLEDpwr, HIGH);
  delay(500);
  digitalWrite(pinLEDpwr, LOW);
  wdt_enable(WDTO_8S);
}

void loop(void) {

    wdt_reset();
  
  wdt_disable();
  readByte = mySerial.read();
  if (readByte == 0xFF) {
  } 
  else { 
    gotByte();
  }
  wdt_enable(WDTO_8S);
  
  wdt_reset();
  ether.packetLoop(ether.packetReceive());
  wdt_reset();

  
wdt_disable();
  readByte = mySerial.read();
  if (readByte == 0xFF) {
  } 
  else { 
    gotByte();
  }
  wdt_enable(WDTO_8S);
  
  
   wdt_reset();

  if (millis() > timer) {
    timer = millis() + 30000;
    sd = stash.create();
    for(int b=0;b<buses; b++)
    {
       wdt_reset();
      getTemperatures(b);
    }


      wdt_reset();

    // uptime in minutes
    minsup = (millis() / 60000);
    stash.print("data:uptime:min:");
    stash.print(devicename);
    stash.print(":");
    stash.println(minsup);


    // loops = polls,
    polled++;
  //  stash.print("data:polled:loops:collector1poll:");
   // stash.println(polled);


    if (minsup > 30)
    {
      Serial.println("restarting...");
     asm volatile (" jmp 0x7C00");  
    }


    // power usage
    if (powerLast > 0) {
      stash.print("data:power:watts:powertotal:");
      stash.println(powerLast);
    }

        wdt_reset();


    // send packet
    if (stash.size() > 0) {  
      stash.save();
      Stash::prepare(PSTR("cmd:add" "\r\n"
        "length:$D" "\r\n"
        "$H"),
      stash.size(),sd);
      ether.tcpSend();
      Serial.println("Updates sent");
      wdt_reset();

    } 
    else {
      Serial.println("No updates to send");
    }
  }
  
   wdt_reset();

}

void getTemperatures(int bus)
{
  byte data[12];
  byte addr[8];
  byte i;
  int d = 0;
  byte present = 0;

  while (ow[bus].search(addr)) {
     wdt_reset();
    d++;
    Serial.print("B=");
    Serial.print(bus);
    Serial.print(" P=");
    Serial.print(owpins[bus]);
    Serial.print(" D=");
    Serial.print(d);
    Serial.print(" A=");
 
    for( i = 0; i < 8; i++) {
      if (addr[i] < 10)
      {
        Serial.print("0"); 
      }
      Serial.print(addr[i], HEX);
    }

    if ( OneWire::crc8( addr, 7) != addr[7]) {
      Serial.println("CRC is not valid!\n");
    }

    tsensor = false;
    addressable = false;
    if ( addr[0] == DS18S20) {
      Serial.print(" DS18S20 ");
      tsensor = true;
    } else if (addr[0] == DS18B20) {
      Serial.print(" DS18B20 "); 
      tsensor = true;
    } else if (addr[0] == DS2405) {
      Serial.print(" DS2405 ");
      addressable = true;
    } else {
      Serial.print(" unknown ");
    }
                  
    ow[bus].reset();
    ow[bus].select(addr);
    
    if (addressable)
    {
      stash.print("data:swit:b:");
      for( i = 0; i < 8; i++) {
        if (addr[i] < 10)
        {
          stash.print("0");
        }
        stash.print(addr[i], HEX);
      }
      stash.print(":");
      
      a = -1;
      b = -1;
      ow[bus].reset();			//reset bus
      ow[bus].select(addr);		 //select device previously discovered
      ow[bus].write(0x55);		  //write status command
      ow[bus].write(0x07);		  //select location 00:07 (2nd byte)
      ow[bus].write(0);		     //select location 00:07 (1st byte)
      ow[bus].write(0x1F);		  //write status data byte (turn PIO-A ON)
           //read CRC16 of command, address and data and print it; we don't care
      for ( i = 0; i < 6; i++) {
        data[i] = ow[bus].read();
      //  Serial.print(data[i], HEX);
      }
      if (data[1] == 0x00)
      {
        a = 0;
      } else if (data[1] = 0xff)
      {
        a = 1;
      }
      
      ow[bus].write(0xFF,1);		//dummy byte FFh to transfer data from scratchpad to status memory, leave the bus HIGH
      delay(500);		     //leave the things as they are for 2 seconds
      ow[bus].reset();
      ow[bus].select(addr);
      ow[bus].write(0x55);
      ow[bus].write(0x07);
      ow[bus].write(0);
      ow[bus].write(0x3F);		  //write status data byte (turn PIO-A OFF)
      for ( i = 0; i < 6; i++) {
        data[i] = ow[bus].read();
        //Serial.print(data[i], HEX);
       }
      if (data[1] == 0x00)
      {
        b = 0;
      } else if (data[1] = 0xff)
      {
        b = 1;
      }
      if (a == 1 || b == 1)
      {
        Serial.print("off");
        stash.println("0");
      } else {
        Serial.print("on"); 
        stash.println("1");
      }
      
      
       
      Serial.print(" ");
      Serial.print(a);
      Serial.print(b);
     
      ow[bus].write(0xFF,1);
      delay(500);
    }
    
    if (tsensor) {
      stash.print("data:temp:c:");
      for( i = 0; i < 8; i++) {
        if (addr[i] < 10)
        {
          stash.print("0");
        }
        stash.print(addr[i], HEX);
      }
      
      ow[bus].write(0x44,1);	   // start conversion, with parasite power on at the end
  
      delay(1000);     // maybe 750ms is enough, maybe not
  
      present = ow[bus].reset();
      ow[bus].select(addr);
      ow[bus].write(0xBE);	   // Read Scratchpad
  
      for ( i = 0; i < 9; i++) {	     // we need 9 bytes
        data[i] = ow[bus].read();
      }
                
      LowByte = data[0];
      HighByte = data[1];
      TReading = (HighByte << 8) + LowByte;
      SignBit = TReading & 0x8000;  // test most sig bit
      if (SignBit) {
        TReading = (TReading ^ 0xffff) + 1; // 2's comp
      }
      if (addr[0] == DS18B20) { /* DS18B20 0.0625 deg resolution */
  	Tc_100 = (6 * TReading) + TReading / 4; // multiply by (100 * 0.0625) or 6.25
      }  else if ( addr[0] == DS18S20) { /* DS18S20 0.5 deg resolution */
  	Tc_100 = (TReading*100/2);
      }
  
      float temp;
  
      if (SignBit) {
  	temp = - (float) Tc_100 / 100;
        } else {
  	temp = (float) Tc_100 / 100;
        }
        Serial.print("*");
        Serial.print(temp);
        Serial.print("*");
        
        stash.print(":");
        stash.println(temp);
    }
      Serial.println("");
  }
   // No more device then reset the search
  ow[bus].reset_search();

}

void gotByte() {
  //Serial.println(readByte);
  if (state == 0) {
    if (readByte == startPattern[pos]) {
      ++pos;
      if (startPattern[pos] == 0) {
        // finished matching start pattern
        ++state;
        power = 0;
      }
    }
    else {
      pos = 0;
    }
  }
  else if (state == 1) {
    if (readByte == endPattern[0]) {
      // finished reading power
      if (power > 0)
      {
        Serial.print("power was ");
        Serial.print(powerLast);
        Serial.print(" now ");
        Serial.println(power);
        powerLast = power;
      }
      state = 0;
    } 
    else {
      // read another digit
      power = power * 10 + readByte - '0';
    }
  }
}

void setupNetwork()
{
  if (ether.begin(sizeof Ethernet::buffer, mymac) == 0) 
    Serial.println( "Failed to access Ethernet controller");
  if (!ether.dhcpSetup())
    Serial.println("DHCP failed");

  ether.printIp("IP:  ", ether.myip);
  ether.printIp("GW:  ", ether.gwip);  
  ether.printIp("DNS: ", ether.dnsip);  

  if (!ether.dnsLookup(website))
    Serial.println("DNS failed");

  ether.printIp("SRV: ", ether.hisip);

  ether.hisport = 81;

}

void OneWireReset(int Pin) // reset.  Should improve to act as a presence pulse
{
     digitalWrite(Pin, LOW);
     pinMode(Pin, OUTPUT); // bring low for 500 us
     delayMicroseconds(500);
    
     pinMode(Pin, INPUT);
     delayMicroseconds(500);
}


