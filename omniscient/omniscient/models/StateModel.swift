//
//  StateModel.swift
//  omniscient
//
//  Created by Antonio Langella on 28/05/22.
//

import Foundation

struct FetchedSensorStatus: Decodable {
    let id: String
    let status: String
}

struct FetchedAnalogDataPoint: Decodable{
    let time: Date
    let value: Double
}

struct FetchedDigitalDataPoint: Decodable{
    let time: Date
    let value: String
}

struct FetchedAnalogSensorData: Decodable {
    let id: String
    let data: [FetchedAnalogDataPoint]
}

struct FetchedDigitalSensorData: Decodable {
    let id: String
    let data: [FetchedDigitalDataPoint]
}

struct FetchedState: Decodable {
    let sensor_status: [String:FetchedSensorStatus]
    let analog_sensor_data: [String:FetchedAnalogSensorData]
    let digital_sensor_data: [String:FetchedDigitalSensorData]
}

struct FetchedAlarmState: Decodable {
    let isAlarmed: Bool
}

class StateModel {
    static let shared = StateModel() //singleton
    var current_state: FetchedState?
    var current_sensor_status: [String:FetchedSensorStatus]?
    //var previous_state: FetchedState?
    var isAlarmed: Bool = false
    
    func fetchState(){
        let stateEndpoint = URL(string: "https://omniscient-app.herokuapp.com/sensors/state")!
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        URLSession.shared.fetchData(for: stateEndpoint,decoder: decoder) { (result: Result<FetchedState, Error>) in
            switch result {
            case .success(let result):
                //print("State fetched successfully",result)
                self.current_state = result
                self.current_sensor_status=result.sensor_status
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.stateChanged, object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name.sensorStatusChanged, object: nil)
                }
            case .failure(let error):
                //print("Couldn't fetch state!")
                print("Couldn't fetch state",error)
            }
        }
        //print(current_state)
        //print("State change notified!")
        //NotificationCenter.default.post(name: NSNotification.Name.stateChanged, object: nil)
    }
    func fetchAlarmState(){
        let alarmEndpoint = URL(string: "https://omniscient-app.herokuapp.com/status/alarmed")!
        URLSession.shared.fetchData(for: alarmEndpoint) { (result: Result<FetchedAlarmState, Error>) in
            switch result {
                case .success(let result):
                    self.isAlarmed=result.isAlarmed
                    //print("ALARMED:",self.isAlarmed)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name.alarmStateChanged, object: nil)
                    }
                case .failure(let error):
                    print("Couldn't fetch alarm state!",error)
            }
        }
    }
    func fetchSensorStatus(){
        let stateEndpoint = URL(string: "https://omniscient-app.herokuapp.com/sensors/connection_status")!
        URLSession.shared.fetchData(for: stateEndpoint) { (result: Result<[String:FetchedSensorStatus], Error>) in
            switch result {
            case .success(let result):
                //print("Sensor status fetched successfully",result)
                self.current_sensor_status=result
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.sensorStatusChanged, object: nil)
                }
            case .failure(let error):
                print("Couldn't fetch sensor status!",error)
            }
        }
    }
}

extension Notification.Name {
    static let stateChanged = Notification.Name("state-changed")
    static let alarmStateChanged = Notification.Name("alarm-state-changed")
    static let sensorStatusChanged = Notification.Name("sensor-status-changed")
}
