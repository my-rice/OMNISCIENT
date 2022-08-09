import UIKit


class AddSensorController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var generalView: UIView!
    @IBOutlet weak var SensorTableView: UITableView!
    
    var room: Room?
    let context = PersistanceController.shared.container.viewContext
    
    var roomMenuItems: [UIAction] {
        let fetchRequest = Room.fetchRequest()
        let rooms = try! context.fetch(fetchRequest)
        return rooms.map(){ room in
            return UIAction(title: room.name!, handler: { _ in
                
            })
        }
    }
    
    var sensorMenuItems: [UIAction] {
        return [
            UIAction(title: "Light",handler:{_ in }),
            UIAction(title: "Temperature",handler:{_ in }),
            UIAction(title: "Movement",handler:{_ in }),
            UIAction(title: "Door",handler:{_ in })
        ]
    }
    
    let content = [
        ["type":"InputText","for":"ID"],
        ["type":"InputText","for":"Name"],
        ["type":"Button","for":"Type"],
    ]
    var values: [String:()->String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SensorTableView.separatorStyle = UITableViewCell.SeparatorStyle.none //Toglie il separatore (divider)
        self.SensorTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        SensorTableView.dataSource = self
        SensorTableView.delegate = self
    }
    
    @IBAction func onSave(_ sender: Any) {
        let sensorID = values["ID"]!()
        let sensorName = values["Name"]!()
        let sensorType = values["Type"]!().uppercased()
        let sensorRoom = room!.name!
        APIHelper.createSensor(sensorID: sensorID, sensorName: sensorName, sensorType: sensorType, sensorRoom: sensorRoom){
            result in
            switch(result){
            case(.success(_)):
                let sensor = Sensor(context:self.context)
                sensor.remoteID=sensorID
                sensor.name=sensorName
                sensor.type=sensorType
                let fetchRequest = Room.fetchRequest()
                fetchRequest.predicate=NSPredicate(format: "name like %@", sensorRoom)
                let room = try! self.context.fetch(fetchRequest).first
                sensor.room = room
                try! self.context.save()
                DispatchQueue.main.async {
                    self.navigationController!.popViewController(animated: true)
                    NotificationCenter.default.post(name: NSNotification.Name.staticDataUpdated, object: nil)
                }
            case(.failure(let e)):
                print("Errore",e)
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let content = self.content[indexPath.row]
        switch (content["type"]!){
        case "InputText":
            let cell: SensorInputTextTableCell = self.SensorTableView.dequeueReusableCell(withIdentifier: "sensorInputTextTableCell", for: indexPath) as! SensorInputTextTableCell
            cell.initialize(for: content["for"]!)
            values.updateValue(cell.getText, forKey: content["for"]!)
            return cell
        //case "Button":
        default:
            let cell: SensorButtonTableCell = self.SensorTableView.dequeueReusableCell(withIdentifier: "sensorButtonTableCell", for: indexPath) as! SensorButtonTableCell
            switch(content["for"]!){
            case "Type":
                let sensorTypeMenu: UIMenu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: sensorMenuItems)
                cell.initialize(for: "Type",menu:sensorTypeMenu)
            //case "Room":
            default:
                let roomMenu: UIMenu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: roomMenuItems)
                cell.initialize(for: "Room",menu:roomMenu)
            }
            values.updateValue(cell.getSelectedItem, forKey: content["for"]!)
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content.count
    }
}

class SensorInputTextTableCell: UITableViewCell{
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    func initialize(for f: String){
        label.text = f
        boxView.layer.cornerRadius = 10
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
    }
    func getText() -> String{
        return textField.text!
    }
}

class SensorButtonTableCell: UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    var menu: UIMenu?
    func initialize(for f: String,menu: UIMenu){
        label.text = f
        self.menu = menu
        button.menu = menu
        button.changesSelectionAsPrimaryAction = true
    }
    func getSelectedItem() -> String{
        return (button.titleLabel?.text)!
    }
}
