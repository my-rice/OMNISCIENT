import Foundation
import Starscream

extension URLSession {
  func fetchData<T: Decodable>(for url: URL, completion: @escaping (Result<T, Error>) -> Void) {
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.setValue(UserDefaults.standard.string(forKey: "authToken"), forHTTPHeaderField: "x-access-token")
        self.dataTask(with: request) { (data, response, error) in
          if let error = error {
            completion(.failure(error))
          }

          if let data = data {
            do {
              let object = try JSONDecoder().decode(T.self, from: data)
              completion(.success(object))
            } catch let decoderError {
              completion(.failure(decoderError))
            }
          }
        }.resume()
    }
    
    func fetchData<T: Decodable>(for url: URL, decoder: JSONDecoder, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UserDefaults.standard.string(forKey: "authToken"), forHTTPHeaderField: "x-access-token")
      self.dataTask(with: request) { (data, response, error) in
        if let error = error {
          completion(.failure(error))
        }

        if let data = data {
          do {
              //print(String(decoding: data, as: UTF8.self))
            let object = try decoder.decode(T.self, from: data)
              //print(object)
            completion(.success(object))
          } catch let decoderError {
            completion(.failure(decoderError))
          }
        }
      }.resume()
    }
    
    func performRequest(forUrl: String,json: [String:Any],method: String,completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: forUrl)!
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(UserDefaults.standard.string(forKey: "authToken"), forHTTPHeaderField: "x-access-token")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request){ (data, response, error) in
            if let error = error {
                print("error")
                completion(.failure(error))
                return
            }
            let res = response as! HTTPURLResponse
            if(res.statusCode != 200){
                print("error")
                let body = String(decoding: data!,as: UTF8.self)
                completion(.failure(NSError(domain: body, code: res.statusCode)))
                return
            }
            print("success")
            completion(.success("SUCCESS"))
        }.resume()
    }
}

struct APITokenResponse: Decodable {
    let username: String
    let accessToken: String
}

struct APIStatusMessageResponse: Decodable {
    enum status: String, Decodable {
        case SUCCESS, ERROR
    }
    let message: String
}

class APIHelper{
    static func createCamera(cameraName: String,roomName: String,domain: String,port: String,username: String,password: String,completion: @escaping (Result<String, Error>) -> Void){
        var json: [String: Any] = [
            "name": cameraName,
            "room_name": roomName,
            "domain": domain,
            "port": port
        ]
        if username != "" {
            json["username"]=username
        }
        if password != "" {
            json["password"]=password
        }
        URLSession.shared.performRequest(forUrl: "https://omniscient-app.herokuapp.com/cameras", json: json, method: "POST", completion: completion)
    }
    static func deleteCamera(cameraName: String, roomName: String,completion: @escaping (Result<String, Error>) -> Void){
        //let url = URL(string: "https://omniscient-app.herokuapp.com/cameras")!
        var json: [String: Any] = [
            "name": cameraName,
            "room_name": roomName
        ]
        URLSession.shared.performRequest(forUrl: "https://omniscient-app.herokuapp.com/cameras", json: json, method: "DELETE", completion: completion)
    }
    
    static func createRoom(roomName: String,color: CIColor,completion: @escaping (Result<String, Error>) -> Void){
        //let url = URL(string: "https://omniscient-app.herokuapp.com/rooms")!
        var json: [String: Any] = [
            "name": roomName,
            "color":[
                "red":color.red,
                "green":color.green,
                "blue":color.blue,
                "alpha":color.alpha
            ]
        ]
        URLSession.shared.performRequest(forUrl: "https://omniscient-app.herokuapp.com/rooms", json: json, method: "POST", completion: completion)
        //print(json)
    }
    
    static func deleteRoom(roomName: String,completion: @escaping (Result<String, Error>) -> Void){
        //let url = URL(string: "https://omniscient-app.herokuapp.com/rooms")!
        var json: [String: Any] = [
            "name": roomName
        ]
        URLSession.shared.performRequest(forUrl: "https://omniscient-app.herokuapp.com/rooms", json: json, method: "DELETE", completion: completion)
    }
    
    static func createSensor(sensorID: String,sensorName: String,sensorType: String, sensorRoom: String,completion: @escaping (Result<String, Error>) -> Void){
        //let url = URL(string: "https://omniscient-app.herokuapp.com/sensors")!
        var json: [String: Any] = [
            "id": sensorID,
            "name": sensorName,
            "type": sensorType,
            "room_name": sensorRoom,
        ]
        URLSession.shared.performRequest(forUrl: "https://omniscient-app.herokuapp.com/sensors", json: json, method: "POST", completion: completion)
    }
    
    static func deleteSensor(sensorID: String,completion: @escaping (Result<String, Error>) -> Void){
        //let url = URL(string: "https://omniscient-app.herokuapp.com/sensors")!
        let json: [String: Any] = [
            "id": sensorID
        ]
        URLSession.shared.performRequest(forUrl: "https://omniscient-app.herokuapp.com/sensors", json: json, method: "DELETE", completion: completion)
    }
    
    static func createSiren(sirenID: String,sirenName: String, completion: @escaping (Result<String, Error>) -> Void){
        //let url = URL(string: "https://omniscient-app.herokuapp.com/sensors")!
        var json: [String: Any] = [
            "id": sirenID,
            "name": sirenName,
            "type": "BUZZER"
        ]
        URLSession.shared.performRequest(forUrl: "https://omniscient-app.herokuapp.com/actuators", json: json, method: "POST", completion: completion)
    }
    
    static func deleteSiren(sirenID: String,completion: @escaping (Result<String, Error>) -> Void){
        //let url = URL(string: "https://omniscient-app.herokuapp.com/sensors")!
        let json: [String: Any] = [
            "id": sirenID
        ]
        URLSession.shared.performRequest(forUrl: "https://omniscient-app.herokuapp.com/actuators", json: json, method: "DELETE", completion: completion)
    }
    
    static func setAlarmed(setAlarmed: Bool, completion: @escaping (Result<String, Error>) -> Void){
        let json: [String: Any] = [
            "setAlarmed": setAlarmed
        ]
        URLSession.shared.performRequest(forUrl: "https://omniscient-app.herokuapp.com/status/alarmed", json: json, method: "POST", completion: completion)
    }
    
    static func login(username: String, password: String, completion: @escaping (Result<APITokenResponse, Error>) -> Void){
        let url = URL(string: "https://omniscient-app.herokuapp.com/auth/login")!
        //let url = URL(string: "https://227d-213-45-207-237.ngrok.io/auth/login")!
        var json: [String: Any] = [
            "username": username,
            "password": password
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request){ (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            let res = response as! HTTPURLResponse
            let body = String(decoding: data!,as: UTF8.self)
            if(res.statusCode != 200){
                completion(.failure(NSError(domain: body, code: res.statusCode)))
                return
            }
            print(body)
            let jsonData = body.data(using: .utf8)!
            let payload: APITokenResponse = try! JSONDecoder().decode(APITokenResponse.self, from: jsonData)
            completion(.success(payload))
        }.resume()
    }
    
    static func signup(username: String, email: String, password: String, completion: @escaping (Result<APIStatusMessageResponse, Error>) -> Void){
        let url = URL(string: "https://omniscient-app.herokuapp.com/auth/signup")!
        var json: [String: Any] = [
            "username": username,
            "password": password,
            "email":email
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request){ (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            let res = response as! HTTPURLResponse
            let body = String(decoding: data!,as: UTF8.self)
            if(res.statusCode != 200){
                completion(.failure(NSError(domain: body, code: res.statusCode)))
                return
            }
            print(body)
            let jsonData = body.data(using: .utf8)!
            let payload: APIStatusMessageResponse = try! JSONDecoder().decode(APIStatusMessageResponse.self, from: jsonData)
            completion(.success(payload))
        }.resume()
    }
    //Classe per la gestione di una sessione del protocollo PSWS: PubSub over WebSocket (definito ad hoc)
    public class PSWSSession: NSObject, WebSocketDelegate{
        private let ws: WebSocket
        private var isConnected: Bool
        private let onConnect: () -> Void
        private let onReceive: (PSWSResponseMessage) -> Void
        var timer: Timer?
        struct PSWSRequestMessage: Encodable {
            let action: String
            let sensor_id: String
        }
        struct PSWSMessage: Decodable{
            let type: String
            let value: String
        }
        struct PSWSResponseMessage: Decodable {
            let topic: String
            let message:PSWSMessage
        }
        
        init(onConnect: @escaping () -> Void, onReceive: @escaping (PSWSResponseMessage) -> Void){
            let url = URL(string: "ws://omniscient-app.herokuapp.com/sensor")!
            //let url = URL(string: "localhost:5000/sensor")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(UserDefaults.standard.string(forKey: "authToken"), forHTTPHeaderField: "x-access-token")
            isConnected=false
            ws = WebSocket(request: request)
            self.onConnect=onConnect
            self.onReceive=onReceive
            super.init()
            ws.delegate = self
        }
        
        func didReceive(event: WebSocketEvent, client: WebSocket) {
            switch event {
            case .connected(let headers):
                isConnected = true
                onConnect()
                print("websocket is connected: \(headers)")
            case .disconnected(let reason, let code):
                isConnected = false
                print("websocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
                //print("Received text: \(string)")
                let object = try! JSONDecoder().decode(PSWSResponseMessage.self, from: Data(string.utf8))
                onReceive(object)
            case .binary(let data):
                print("Received data: \(data.count)")
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                isConnected = false
            case .error(let error):
                isConnected = false
                print("Error:",error)
            }
        }
        
        func subscribe(sensorID: String){
            //let encoder: JSONEncoder = JSONEncoder.init()
            //let data: Data = try! encoder.encode(PSWSRequestMessage(action: "subscribe", sensor_id: sensorID))
            ws.write(string: "{\"sensor_id\":\"\(sensorID)\",\"action\":\"subscribe\"}")
            print("{\"sensor_id\":\"\(sensorID)\",\"action\":\"subscribe\"}")
        }
        
        func connect(){
            ws.connect()
            timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.ping), userInfo: nil, repeats: true)
        }
        
        func disconnect(){
            timer?.invalidate()
            timer = nil
            ws.forceDisconnect()
        }
        
        @objc func ping(){
            //print("ping")
            ws.write(ping: Data("ping".utf8))
        }
        
        deinit{
            timer?.invalidate()
            timer = nil
            ws.disconnect(closeCode: 0)
        }
    }
}
