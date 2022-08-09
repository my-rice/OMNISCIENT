import UIKit
import CoreData
import GaugeKit


enum sensorType: String {
    case MOVEMENT,TEMPERATURE,LIGHT,DOOR,WINDOW
}


class RoomController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate  {
    //UICollectionViewDelegateFlowLayout va messo perchè è una collection view
    @IBOutlet weak var roomCollectionView: UICollectionView!
    var titleRoom: String = ""
    var roomName: String?
    
    let context = PersistanceController.shared.container.viewContext
    var room: Room? {
        let fetchRequest = Room.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", roomName!)
        let room = try! context.fetch(fetchRequest).first
        return room
    }
    var sensorList: [Sensor] {
        print("sensorList requested")
        let sensors: [Sensor] = room?.sensors?.allObjects as? [Sensor] ?? []
        return sensors
    }
    /*
     Dizionario che mappa gli i sensori nella stanza alle UICollectionViewCell destinatarie dei messaggi
     inviate dai sensori
     */
    var psws: APIHelper.PSWSSession?
    var messageRecipients: [String:Updatable] = [:]
    var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = titleRoom
        roomCollectionView.dataSource = self
        roomCollectionView.delegate = self
        roomCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.staticDataUpdated, object: nil)
        
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let sensor = sensorList[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                print("Delete cell at \(indexPath)")
                APIHelper.deleteSensor(sensorID: sensor.remoteID!){
                    result in
                    switch(result){
                    case .success(_):
                        DispatchQueue.main.async {
                            self.roomCollectionView.cellForItem(at: indexPath)?.prepareForReuse()
                            self.context.delete(sensor)
                            try! self.context.save()
                            NotificationCenter.default.post(name: NSNotification.Name.staticDataUpdated, object: nil)
                        }
                    case .failure(let e):
                        print("Error",e)
                    }
                }
            }
            return UIMenu(title: "", children: [delete])
        }
    }
    
    
    @objc func contextObjectsDidChange(_:Any){
        DispatchQueue.main.async {
            self.roomCollectionView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        //Controllo lo stato iniziale dei sensori
        StateModel.shared.fetchState()
        //Sottoscrizione a tutti i topic di interesse
        psws=APIHelper.PSWSSession(onConnect: {
            self.messageRecipients.keys.forEach{x in
                self.psws!.subscribe(sensorID: x)
            }
        }, onReceive: { res in
            self.messageRecipients[res.topic]?.updateUI(res.message)
        })
        psws!.connect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //Unsubscribe dai topic di interesse
        psws!.disconnect()
        psws=nil
    }
    
    //Numero di Item che devono essere mostrati a video
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sensorList.count
    }
    
    //Configuro quale cella della collectionView deve essere mostrata
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sensor = sensorList[indexPath.row]
        
        if sensor.type! == "TEMPERATURE" || sensor.type! == "LIGHT" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "analogTableCell", for: indexPath) as! AnalogTableCell
            cell.initialize(sensor: sensor)
            messageRecipients.updateValue(cell, forKey: sensor.remoteID!)
            cell.setDisabled()
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "digitalTableCell", for: indexPath) as! DigitalTableCell
            cell.initialize(sensor: sensor)
            messageRecipients.updateValue(cell, forKey: sensor.remoteID!)
            cell.setDisabled()
            return cell
        }
            
    }
    
    //Questa funzione mi permette effettivamente di scegliere il layout fornendo le dimensioni delle celle della CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Agendo qui è possibile adattare la Collection ad esempio mettendo la possibilità di scrollare a destra.
        return CGSize(width: 202, height: 211)
        
    }
    
    //Cliccare qui equivale a svolgere delle azioni quando viene premuta una determinata cella
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(sensorList[indexPath.row].name ?? "Sensore sconosciuto")
        
    }
    
    //Funzione chiamata prima del segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var sensor: Sensor? = nil
        if let analogTableCell = sender as? AnalogTableCell {
            sensor = analogTableCell.getSensor()
        }
        
        if let digitalTableCell = sender as? DigitalTableCell {
            sensor = digitalTableCell.getSensor()
        }
        
        if let analogChartController = segue.destination as? AnalogChartController {
            analogChartController.initialize(sensor: sensor!)
        }
        
        if let digitalChartController = segue.destination as? DigitalChartController {
            digitalChartController.initialize(sensor: sensor!)
        }
        if let addSensorController = segue.destination as? AddSensorController{
            addSensorController.room=self.room
        }
    }
    
    func setTitle(title: String){
        titleRoom = title
    }
    
}

protocol Updatable {
    func updateUI(_: APIHelper.PSWSSession.PSWSMessage) -> Void
}

class AnalogTableCell: UICollectionViewCell, Updatable  {
    //nota: provare prima con CollectionView UITableViewCell
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var analogView: UIView!
    @IBOutlet weak var barIndicator: Gauge! // bar nel senso di barra circolare!!!
    var sensor: Sensor?
    var nomeSensore: String = ""
    var defaultValueSensor: Double = 0.0
    var status: FetchedSensorStatus? {
        return StateModel.shared.current_sensor_status?[sensor!.remoteID!]
    }
    
    func initialize(sensor: Sensor) {
        //Qui viene definito il template del analogView
        analogView.layer.cornerRadius = 12
        self.sensor=sensor
        self.setNameSensor(nameSensor: sensor.name ?? "")
        
        if sensor.type == "TEMPERATURE"{
            defaultValueSensor = 30.0
            self.setRate(currentRate: defaultValueSensor)
            self.setInfoSensor(info: String(Int(defaultValueSensor)) + " °C")
            self.setMaxValue(maxValue: 37)
            self.setStartColor(color: UIColor.link)
            self.setEndColor(color: UIColor.systemRed)
            self.setBgColor(color: UIColor.yellow)
        }else if sensor.type == "LIGHT" {
            defaultValueSensor = 400.0
            self.setRate(currentRate: defaultValueSensor)
            self.setInfoSensor(info: String(Int(defaultValueSensor)) + "  lx")
            self.setMaxValue(maxValue: 700)
            self.setStartColor(color: UIColor.yellow)
            self.setEndColor(color: UIColor.yellow)
            self.setBgColor(color: UIColor.yellow)
        }else{
            //Sensore sconosciuto di cui non si sa nulla
            self.setRate(currentRate: defaultValueSensor)
            self.setInfoSensor(info: String(Int(defaultValueSensor)))
            self.setMaxValue(maxValue: 100)
            self.setStartColor(color: UIColor.link)
            self.setEndColor(color: UIColor.systemRed)
            self.setBgColor(color: UIColor.yellow)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus), name: NSNotification.Name.sensorStatusChanged, object: nil)
    }
    
    func setMaxValue(maxValue: Double){
        barIndicator.maxValue = CGFloat(maxValue)
    }
    func setRate(currentRate: Double){
        barIndicator.rate = CGFloat(currentRate)
    }
    func setStartColor(color: UIColor){
        barIndicator.startColor = color
    }
    func setEndColor(color: UIColor){
        barIndicator.endColor = color
    }
    func setBgColor(color: UIColor){
        barIndicator.bgColor = color
    }

    func setNameSensor(nameSensor: String) {
        titleLabel.text = nameSensor
        nomeSensore = nameSensor
    }
    func setInfoSensor(info: String) {
        infoLabel.text = info
    }
    
    func getSensor() -> Sensor {
        return sensor!
    }
    
    func getNameSensor() -> String {
        return nomeSensore
    }
    
    func setDisabled(){
        self.isUserInteractionEnabled=false
        self.contentView.alpha = 0.2
    }
    
    func setEnabled(){
        self.isUserInteractionEnabled=true
        self.contentView.alpha = 1
    }
    
    @objc func updateStatus(){
        if(status?.status=="CONNECTED"){
            self.setEnabled()
        } else {
            self.setDisabled()
        }
    }
    
    func updateUI(_ msg:APIHelper.PSWSSession.PSWSMessage) {
        if(msg.type=="sensor_status"){
            if(msg.value != "CONNECTED"){
                self.setDisabled()
                return
            } else {
                self.setEnabled()
                return
            }
        } else if (msg.type=="sensor_value") {
            self.setEnabled()
            let value = Double(msg.value)!
            self.setRate(currentRate: value)
            switch(sensor?.type){
            case "TEMPERATURE":
                self.setInfoSensor(info: String(format:"%.1f °C",value))
            case "LIGHT":
                self.setInfoSensor(info: String(format:"%.0f lux",value))
            default:
                self.setInfoSensor(info: String(value))
            }
        }
    }
    deinit { //Viene chiamato quando la cella non è più mostrata
        NotificationCenter.default.removeObserver(self)
        print("deinit")
    }
}

class DigitalTableCell: UICollectionViewCell, Updatable  {
    @IBOutlet weak var digitalSensor: UILabel!
    @IBOutlet weak var digitalIconImage: UIImageView!
    @IBOutlet weak var digitalView: UIView!
    
    var sensor: Sensor?
    var connection_status: String? {
        return StateModel.shared.current_sensor_status?[sensor!.remoteID!]?.status
    }
    var door_status: String? {
        return StateModel.shared.current_state?.digital_sensor_data[sensor!.remoteID!]?.data[0].value
    }
    func initialize(sensor: Sensor){
        //Qui viene definito il template del analogView
        digitalView.layer.cornerRadius = 12
        digitalIconImage.layer.cornerRadius = 12
        self.sensor=sensor
        digitalSensor.text = sensor.name
        if sensor.type == "MOVEMENT"{
            digitalIconImage.image = UIImage(named: "movement-sensor")
        }else if sensor.type == "DOOR" {
            digitalIconImage.image = UIImage(named: "door-closed")
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateStatus), name: NSNotification.Name.stateChanged, object: nil)
    }
    func getSensor() -> Sensor {
        return sensor!
    }
    
    func getSensorName() -> String {
        return sensor!.name!
    }
    
    @objc func updateStatus(){
        if(connection_status=="CONNECTED"){
            self.setEnabled()
            if(sensor!.type!=="DOOR"){
                if door_status != "CLOSED" {
                    digitalIconImage.image = UIImage(named: "door-open")
                } else {
                    digitalIconImage.image = UIImage(named: "door-closed")
                }
            }
        } else {
            self.setDisabled()
        }
    }
    
    func updateUI(_ msg:APIHelper.PSWSSession.PSWSMessage) {
        if(msg.type=="sensor_status"){
            if(msg.value != "CONNECTED"){
                self.setDisabled()
                return
            } else {
                self.setEnabled()
                return
            }
        } else if (msg.type=="sensor_value") {
            self.setEnabled()
            if sensor?.type != "DOOR" {
                return
            }
            let value = msg.value
            if value != "CLOSED" {
                digitalIconImage.image = UIImage(named: "door-open")
            } else {
                digitalIconImage.image = UIImage(named: "door-closed")
            }
        }
    }

    func setDisabled(){
        self.isUserInteractionEnabled=false
        self.contentView.alpha = 0.2
    }
    
    func setEnabled(){
        self.isUserInteractionEnabled=true
        self.contentView.alpha = 1
    }
    deinit { //Viene chiamato quando la cella non è più mostrata
        NotificationCenter.default.removeObserver(self)
        print("deinit")
    }
}

