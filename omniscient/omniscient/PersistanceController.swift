//
//  PersistanceController.swift
//  smartTrip
//
//  Created by Antonio Langella on 15/02/22.
//
import CoreData
import SwiftUI

struct PersistanceController{
    static let shared = PersistanceController(inMemory: false) //Singleton. Sto costruendo la classe stessa!!!
    //TODO: In fase di produzione togliere inMemory: true
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false){
        container = NSPersistentContainer(name: "Model") //il nome del modello dev'essere lo stesso del file
        if inMemory { //Se inMemory == true, i dati vanno salvati in un file temporaneo
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        //Altrimenti genera lui il nome del file ed esso non sarà volatile
        container.loadPersistentStores(completionHandler: {storeDescription,error in
            if let error = error as NSError?{
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }) //completionHandler viene eseguita dopo il caricamento e gestisce eventuali errori in fase di caricamento
    }
    
    static var preview: PersistanceController = { //Parte extra per gestire le preview.
        let result = PersistanceController(inMemory: true) //Inizializza un contenitore volatile con elementi fittizzi
        let viewContext = result.container.viewContext
        generateDummyContent(context: viewContext)
        do{
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    private static func generateDummyContent(context: NSManagedObjectContext){
        let bedroom = Room(context: context)
        bedroom.name = "Camera da letto"
        let camera = Camera(context: context)
        camera.name = "Telecamera 1"
        camera.domain = "wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4"
        camera.port = 554
        camera.username = nil
        camera.password = nil
        camera.composition = bedroom
        let camera2 = Camera(context: context)
        camera2.name = "Telecamera 2"
        camera2.domain = "wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4"
        camera2.port = 554
        camera2.username = nil
        camera2.password = nil
        camera2.composition = bedroom
    }
    
    public static func deleteAllStaticContent(context: NSManagedObjectContext){
        var fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Camera")
        var deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
        }
        fetchRequest = NSFetchRequest(entityName: "Sensor")
        deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
        }
        fetchRequest = NSFetchRequest(entityName: "Room")
        deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
        }
        fetchRequest = NSFetchRequest(entityName: "Actuator")
        deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch let error as NSError {
            // TODO: handle the error
        }
    }
    
    private static func extractRoomImages(context: NSManagedObjectContext) -> [String:Data]{
        let fetchRequest = Room.fetchRequest()
        fetchRequest.predicate=NSPredicate(format:"hasImage = true")
        let rooms = try! context.fetch(fetchRequest)
//        print("RISULTATO QUERY")
//        print(rooms)
        let roomImages: [String:Data] = rooms.reduce(into: [String:Data]()){
            res, room in
            res[room.name!]=room.image
        }
        //print(roomImages)
        return roomImages
    }
    
    public static func fetchStaticContent(context: NSManagedObjectContext){
        let cameraEndpoint = URL(string: "https://omniscient-app.herokuapp.com/cameras")!
        let roomEndpoint = URL(string: "https://omniscient-app.herokuapp.com/rooms")!
        let sensorEndpoint = URL(string: "https://omniscient-app.herokuapp.com/sensors")!
        let actuatorEndpoint = URL(string: "https://omniscient-app.herokuapp.com/actuators")!
        
        //print("FetchStaticContent started")
        let group = DispatchGroup()
        var allSuccessful = true
        var fetchedRooms: [FetchedRoom] = []
        var fetchedCameras: [FetchedCamera] = []
        var fetchedSensors: [FetchedSensor] = []
        var fetchedActuators: [FetchedActuator] = []
        
        group.enter()
        URLSession.shared.fetchData(for: roomEndpoint) { (result: Result<[FetchedRoom], Error>) in
            switch result {
                case .success(let result):
                //print("Rooms fetched successfully",result)
                fetchedRooms=result
                case .failure(let error):
                //print("Couldn't fetch rooms",error)
                allSuccessful = false
            }
            group.leave()
        }
        group.enter()
        URLSession.shared.fetchData(for: cameraEndpoint) { (result: Result<[FetchedCamera], Error>) in
            switch result {
                case .success(let result):
                //print("Cameras fetched successfully",result)
                fetchedCameras=result
                case .failure(let error):
                //print("Couldn't fetch cameras",error)
                allSuccessful = false
            }
            group.leave()
        }
        group.enter()
        URLSession.shared.fetchData(for: sensorEndpoint) { (result: Result<[FetchedSensor], Error>) in
            switch result {
                case .success(let result):
                //print("Sensors fetched successfully",result)
                fetchedSensors = result
                case .failure(let error):
                //print("Couldn't fetch sensors",error)
                allSuccessful = false
            }
            group.leave()
        }
        group.enter()
        URLSession.shared.fetchData(for: actuatorEndpoint) { (result: Result<[FetchedActuator], Error>) in
            switch result {
                case .success(let result):
                //print("Sensors fetched successfully",result)
                fetchedActuators = result
                case .failure(let error):
                //print("Couldn't fetch sensors",error)
                allSuccessful = false
            }
            group.leave()
        }
        group.notify(queue: DispatchQueue.global()){ //TODO: Controllare se viene eseguito solo al termine dei 3 task
            if(!allSuccessful){
                return
            }
            //print("All tasks completed successfully")
            //ESTRAI LE ANTEPRIME DA COREDATA
            let roomImages=extractRoomImages(context: context)
            //CANCELLA I DATI STATICI
            deleteAllStaticContent(context: context)
            var roomDict = Dictionary<String,Room>()
            for room in fetchedRooms {
                roomDict[room.name]=Room(context: context)
                roomDict[room.name]?.name=room.name
                roomDict[room.name]?.colorRed=Float(room.color.red)!
                roomDict[room.name]?.colorGreen=Float(room.color.green)!
                roomDict[room.name]?.colorBlue=Float(room.color.blue)!
                roomDict[room.name]?.colorAlpha=Float(room.color.alpha)!
                if roomImages.keys.contains(room.name) {
                    roomDict[room.name]?.hasImage=true
                    roomDict[room.name]?.image=roomImages[room.name]
                }
                else {
                    roomDict[room.name]?.hasImage=false
                }
            }
            var cameraDict = Dictionary<String,Camera>()
            for camera in fetchedCameras {
                cameraDict[camera.name]=Camera(context: context)
                cameraDict[camera.name]?.name=camera.name
                cameraDict[camera.name]?.domain=camera.domain
                cameraDict[camera.name]?.port=Int16(camera.port)!
                cameraDict[camera.name]?.username=camera.username
                cameraDict[camera.name]?.password=camera.password
                cameraDict[camera.name]?.composition=roomDict[camera.room_name]
            }
            var sensorDict = Dictionary<String,Sensor>()
            for sensor in fetchedSensors {
                sensorDict[sensor.name]=Sensor(context: context)
                sensorDict[sensor.name]?.name=sensor.name
                sensorDict[sensor.name]?.remoteID=sensor.id
                sensorDict[sensor.name]?.type=sensor.type
                sensorDict[sensor.name]?.room=roomDict[sensor.room_name]
            }
            print("BBBBBBBB")
            var actuatorDict = Dictionary<String,Actuator>()
            for actuator in fetchedActuators {
                actuatorDict[actuator.name]=Actuator(context: context)
                actuatorDict[actuator.name]?.name=actuator.name
                actuatorDict[actuator.name]?.remoteID=actuator.id
                actuatorDict[actuator.name]?.type=actuator.type
                print("AAAAAAA")
            }
            do {
                try context.save()
                NotificationCenter.default.post(name: .staticDataUpdated, object: nil)
            } catch let error as NSError {
                // TODO: handle the error
            }
        }
    }
}


extension Notification.Name {
    static let staticDataUpdated = Notification.Name("static-data-updated")
}
