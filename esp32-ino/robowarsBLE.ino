
#include <Arduino.h>
#include <analogWrite.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"

#define SERVICE_UUID "ab0828b1-198e-4351-b779-901fa0e0371e"
#define MESSAGE_UUID "4ac8a682-9736-4e5d-932b-e9b31405049c"

#define DEVINFO_UUID (uint16_t)0x180a
#define DEVINFO_MANUFACTURER_UUID (uint16_t)0x2a29
#define DEVINFO_NAME_UUID (uint16_t)0x2a24
#define DEVINFO_SERIAL_UUID (uint16_t)0x2a25

#define DEVICE_MANUFACTURER "Mobiler"
#define DEVICE_NAME "RobotA"


int AIB = 27 ;
int AIA = 26 ;
int BIB = 19 ;
int BIA = 18 ;

ESP32 
L298N Voltaj Regulatörlü Çift Motor Sürücü Kartı 
Dişi-Erkek ve Dişi-Dişi Jumper kablolar
Yardımcı Breadboard 
9 V Pil ve Pil Başlığı 
Araç kasa ve lastikler + 2 adet 6 V motor


class MyServerCallbacks : public BLEServerCallbacks
{
    void onConnect(BLEServer *server)
    {
      Serial.println("Connected");
      analogWrite(AIA, 0);
      analogWrite(AIB, 0);
      analogWrite(BIA, 0);
      analogWrite(BIB, 0);
    };

    void onDisconnect(BLEServer *server)
    {
      Serial.println("Disconnected");
      analogWrite(AIA, 0);
      analogWrite(AIB, 0);
      analogWrite(BIA, 0);
      analogWrite(BIB, 0);
    }
};

class MessageCallbacks : public BLECharacteristicCallbacks
{
    void onWrite(BLECharacteristic *characteristic)
    {

      int sa[4], r = 0, t = 0;
      std::string data = characteristic->getValue();
      Serial.println(data.c_str());

      String message = data.c_str();

      for (int i = 0; i < message.length(); i++)
      {
        if (message.charAt(i) == ';')
        {
          sa[t] = message.substring(r, i).toInt();
          r = (i + 1);
          t++;
        }
      }

      Serial.println("sagIleri:");
      Serial.println(sa[0]);
      Serial.println("sagGeri:");
      Serial.println(sa[1]);
      Serial.println("solIleri:");
      Serial.println(sa[2]);
      Serial.println("solGeri:");
      Serial.println(sa[3]);

      analogWrite(AIA, sa[0]);
      analogWrite(AIB, sa[1]);
      analogWrite(BIA, sa[2]);
      analogWrite(BIB, sa[3]);
    }

    void onRead(BLECharacteristic *characteristic)
    {
      characteristic->setValue("Robowars");
    }
};

void setup()
{
  delay(1000);
  Serial.begin(115200);
    
  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0);
  pinMode(AIA, OUTPUT); // set pins to output
  pinMode(AIB, OUTPUT);
  pinMode(BIA, OUTPUT);
  pinMode(BIB, OUTPUT);

  // Setup BLE Server
  BLEDevice::init(DEVICE_NAME);
  BLEServer *server = BLEDevice::createServer();
  server->setCallbacks(new MyServerCallbacks());

  // Register message service that can receive messages and reply with a static message.
  BLEService *service = server->createService(SERVICE_UUID);
  BLECharacteristic *characteristicMessage = service->createCharacteristic(MESSAGE_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_WRITE);
  characteristicMessage->setCallbacks(new MessageCallbacks());
  characteristicMessage->addDescriptor(new BLE2902());
  service->start();

  // Register device info service, that contains the device's UUID, manufacturer and name.
  service = server->createService(DEVINFO_UUID);
  BLECharacteristic *characteristic = service->createCharacteristic(DEVINFO_MANUFACTURER_UUID, BLECharacteristic::PROPERTY_READ);
  characteristic->setValue(DEVICE_MANUFACTURER);
  characteristic = service->createCharacteristic(DEVINFO_NAME_UUID, BLECharacteristic::PROPERTY_READ);
  characteristic->setValue(DEVICE_NAME);
  characteristic = service->createCharacteristic(DEVINFO_SERIAL_UUID, BLECharacteristic::PROPERTY_READ);
  String chipId = String((uint32_t)(ESP.getEfuseMac() >> 24), HEX);
  characteristic->setValue(chipId.c_str());
  service->start();

  // Advertise services
  BLEAdvertising *advertisement = server->getAdvertising();
  BLEAdvertisementData adv;
  adv.setName(DEVICE_NAME);
  adv.setCompleteServices(BLEUUID(SERVICE_UUID));
  advertisement->setMinPreferred(0x06);
  advertisement->setAdvertisementData(adv);
  advertisement->start();

  Serial.println("Ready");
}

void loop()
{
  //delay(1000);
}
