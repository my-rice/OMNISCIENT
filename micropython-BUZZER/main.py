#OMNISCIENT
from umqttsimple import MQTTClient
from machine import Pin
import utime

#Gestione della connessione durante tutta l'attività del sensore smart/attuatore smart
while True:
    if station.isconnected() == False:
        #In caso di disconnessione il sensore prova a riconettersi
        led_pin = machine.PWM(machine.Pin(0), freq=4)
        led_pin.duty(512)
        print('connection problem, trying to reconnect')
        station.connect(ssid, password)
        i = 0
        while station.isconnected() == False:
            print('trying to reconnect')
            i = i + 1
            utime.sleep_ms(1000)
            if i >= 300:
                led_pin.deinit()
                raise Exception

        print('Connection successful')
        print(station.ifconfig())

        #Calcolo il nuovo session id 
        try:
            f = open('session_id', 'r')
            session_id = int(f.read())
            f.close()
        except OSError:
            print('file non aperto')

        print ('old session id:', session_id)
        session_id = (session_id + 1) % 100

        try:
            f = open('session_id', 'w')
            f.write(str(session_id))
            f.close()
        except OSError:
            print('non riesco a scrivere')

        print ('new session id:', session_id)

        #Il sensore si riconnette al broker MQTT con il nuovo session id
        value = 'DISCONNECTED'
        payload = {'session-id': session_id, 'value': value}
        c.set_last_will(topic_disconnect, json.dumps(payload))

        c.connect()
        value = 'CONNECTED'
        payload = {'session-id': session_id, 'value': value}
        c.publish(topic_connect, json.dumps(payload))  # converte qualsiasi oggetto in una stringa in formatoJSON

        led_pin.deinit()
        led_pin = Pin(0, Pin.OUT)
    else:
        utime.sleep_ms(1000)
        try:
            #Il sensore invia un ping al server (broker MQTT) per non farsi disconettere allo scadere del keep-alive. Tale azione è utile nel caso in cui non vengano inviati messaggi al broker
            c.ping()
            #Il sensore controlla i messaggi di BROADCAST
            c.check_msg()
        except OSError:
            print ('errore dal check message PING o dal PING con il server')
