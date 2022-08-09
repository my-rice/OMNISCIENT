# OMNISCIENT
## What is "Omniscient"?
"Omniscient" is a system that aims to monitor the home environment through smart sensors and actuators and to make people feel safer by integrating cameras and the ability to carry out dissuasive actions.

"Omniscient" is made up of several parts: a mobile application entitled "Omniscient", intelligent devices that belong to the world of the Internet of Things and a back end that interfaces all the components of the system using two databases (one relational and one time series) and communicates with smart devices through a server agent.

## "Omniscient" scheme:
![Omniscient structure](/assets/images/Omniscient-Scheme.png)

## "Omniscient" folder:
The "Omniscient" folder contains the iOS application code that acts as a frontend for the system, connecting to smart devices via the backend.

### The "backend" folder contains:

- the telegraf configuration file (telegraf.conf)
- the relational database creation scripts (pg-scripts)
- the code of the api written in Node.js (omniscient-api)
### Folders starting with the micropython- prefix contain the firmware of smart devices. In particular:

- micropython-ANALOG contains the firmware of the analog sensors
- micropython-DIGITAL contains the firmware of the digital sensors
- micropython-BUZZER contains the firmware of the smart acoustic sirens
## Controllers Scheme:
![Omniscient controllers structure](/assets/images/controller_scheme.png)
## Contributors:
1. @my-rice
2. @AntoSave