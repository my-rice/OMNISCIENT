import UIKit


class AddSirenController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet var generalView: UIView!
    @IBOutlet weak var addSirenTableView: UITableView!
    
    let content = ["ID","Name"]
    var values: [String:()->String] = [:]
    let context = PersistanceController.shared.container.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSirenTableView.separatorStyle = UITableViewCell.SeparatorStyle.none //Toglie il separatore (divider)
        self.addSirenTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        addSirenTableView.dataSource = self
        addSirenTableView.delegate = self
    }
    
    @IBAction func onSave(_ sender: Any) {
        let actuatorID = values["ID"]!()
        let actuatorName = values["Name"]!()
        APIHelper.createSiren(sirenID: actuatorID, sirenName: actuatorName){
            result in
            switch(result){
            case(.success(_)):
                let actuator = Actuator(context:self.context)
                actuator.remoteID=actuatorID
                actuator.name=actuatorName
                actuator.type="BUZZER"
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

        let cell: SirenInputTextTableCell = self.addSirenTableView.dequeueReusableCell(withIdentifier: "sirenInputTextTableCell", for: indexPath) as! SirenInputTextTableCell
        
        let name: String = content[indexPath.row]
        cell.initialize(f: name)
        values.updateValue(cell.getText, forKey: content[indexPath.row])
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content.count
    }
}

class SirenInputTextTableCell: UITableViewCell{
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var boxView: UIView!
    
    
    func initialize(f: String){
        label.text = f
        boxView.layer.cornerRadius = 10
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .none
    }
    func getText() -> String{
        return textfield.text!
    }
}

