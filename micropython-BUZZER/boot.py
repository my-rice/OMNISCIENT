#OMNISCIENT
import utime
from umqttsimple import MQTTClient
import ubinascii
import machine
from machine import Pin
import network
import json

#Gestione del valore del buzzer
value = False

#Gestione del session id all'avvio
session_id=0

try:
  f=open('session_id','r')
  session_id=int(f.read())
  f.close()
except OSError:
  print("file non aperto")

print("old session id:", session_id)      
session_id=(session_id + 1)%100

#inizializzazione del led in PWM per ricerca rete internet
led_pin = machine.PWM(machine.Pin(0), freq=4)
buzzer_pin = machine.PWM(machine.Pin(2), freq=1023)
buzzer_pin.duty(0)

try:
  f = open('session_id', 'w')
  f.write(str(session_id))
  f.close()
except OSError:
  print("non riesco a scrivere")

print("new session id:", session_id)

#Apertura file JSON per configurare il sensore 
with open('config.json') as file:
  CONFIG = json.load(file)
#print(CONFIG,CONFIG["ssid"])

period_ms= CONFIG["period_ms"] #ogni quanto verifico fronte
led_on_time_ms= CONFIG["led_on_time_ms"] #durata accensione led'''

#CONNECT WI-FI
ssid = CONFIG["ssid"]
password = CONFIG["password"]
mqtt_server = CONFIG["mqtt_server"]
#EXAMPLE IP ADDRESS
client_id = ubinascii.hexlify(machine.unique_id())
#mqtt_user=b'admin'
mqtt_user= CONFIG["mqtt_user"]
mqtt_password= CONFIG["mqtt_password"]
topic_pub= CONFIG["topic_pub"]
type_SENSOR= CONFIG["type_SENSOR"]

topic_connect= str(topic_pub) + "/" + str(type_SENSOR) +  "/" + client_id.decode('ascii') + "/CONNECTED"
topic_disconnect= str(topic_pub) + "/" + str(type_SENSOR) + "/" + client_id.decode('ascii') + "/DISCONNECTED"
topic_value= str(topic_pub) + "/" + str(type_SENSOR) + "/" +client_id.decode('ascii') + "/VALUE"
topic_enable = str(topic_pub) + "/" + str(type_SENSOR) + "/" +client_id.decode('ascii') + "/STATE"

#Funzione per la gestione del PING di broadcast
def broadcast(topic,msg):
  if topic == b'OMNISCIENT/BROADCAST' and msg == b'PING':
    print("rispondo al ping, con session_id:", session_id, "e stato attuale:", last_value)
    value="CONNECTED"
    payload={"session-id": session_id, "value": value}
    c.publish(topic_connect,json.dumps(payload))

def buzzer_wait(topic,msg):
  global value
  global topic_enable
  global topic_value
  global buzzer_pin

  topic = topic.decode('utf-8')
  #if topic == b'OMNISCIENT/BUZZER/be9c0b00/STATE':
  if topic == topic_enable:
    if msg == b'ON':
      value = True
      buzzer_pin.duty(512)
    elif msg == b'OFF':
      value = False
      buzzer_pin.duty(0)
      
    print('Buzzer:',value,', publishing to topic',topic_value)
    payload={"session-id": session_id, "value": str(value)}
    try:
      c.publish(topic_value,json.dumps(payload))  
    except OSError:
      print("Couldn't publish data!!!")
    
#Gestione della connessione ad Internet
last_message = 0
message_interval = 5
counter = 0

station = network.WLAN(network.STA_IF)
station.active(True)
station.connect(ssid, password)

i=0
led_pin.duty(512)
while station.isconnected() == False:
  utime.sleep_ms(1000)

  print("trying to connect")
  i=i+1
  if i>=30:
    led_pin.deinit()
    led_pin=Pin(0,Pin.OUT)
    raise Exception

led_pin.deinit()
led_pin=Pin(0,Pin.OUT)
print('Connection successful')
print(station.ifconfig())

#Definizione client MQTT
c = MQTTClient(client_id, mqtt_server,user=mqtt_user,password=mqtt_password,keepalive=5) #keep live in sec
value="DISCONNECTED"
payload={"session-id": session_id, "value": value}

c.set_last_will(topic_disconnect,json.dumps(payload))
c.set_callback(broadcast)
c.set_callback(buzzer_wait)
c.connect()

value="CONNECTED"
payload={"session-id": session_id, "value": value}
c.publish(topic_connect,json.dumps(payload))
c.subscribe("OMNISCIENT/BROADCAST")
c.subscribe(str(topic_enable))