import Foundation
import UIKit


class controlPanelController: UITableViewController {
    @IBOutlet weak var stateColor: UIView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var imageState: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch!
    
    @IBOutlet weak var sectionOne: UIView!
    @IBOutlet weak var sirenView: UIView!
    @IBOutlet weak var sirenLabel: UILabel!
    @IBOutlet weak var sirenImage: UIImageView!
    @IBOutlet weak var displacementIndicatorImage: UIImageView!
    
    var state_armed: Bool {
        return StateModel.shared.isAlarmed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        navigationItem.title = "Settings"
        
        stateColor.layer.cornerRadius = min(stateColor.frame.size.height, stateColor.frame.size.width) / 2.0
        stateColor.clipsToBounds = true
        displacementIndicatorImage.image = UIImage(systemName: "chevron.right")
        
        sectionOne.layer.cornerRadius = 20
        sirenView.layer.cornerRadius = 20
        //Inizializzo il sistema al valore corrente
        print("state_armed",state_armed)
        stateSwitch.setOn(state_armed, animated: false)
        print("state_armed",state_armed)
        stateSwitch.setOn(state_armed, animated: false)
        self.updateUIHelper()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI(notification:)), name: NSNotification.Name.alarmStateChanged, object: nil)
        self.initializeAlarm()
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.logout, object: nil)
    }
    
    @IBAction func switchDidChange(_ sender: UISwitch) {
        print("switchDidChange","setAlarmed:",sender.isOn)
        APIHelper.setAlarmed(setAlarmed: sender.isOn){
            result in
            switch(result){
            case(.success(_)):
                StateModel.shared.fetchAlarmState()
            case(.failure(let e)):
                print("Errore",e)
            }
        }
    }
    
    @objc func updateUI(notification: NSNotification){
        print("SONO QUI",state_armed)
        updateUIHelper()
    }
    func updateUIHelper(){
        //DispatchQueue.main.async {
        if(self.state_armed == true){
            self.stateColor.backgroundColor = .green
            self.imageState.image = UIImage(named: "close-lock")
            
            self.firstLabel.text = "The system is ARMED"
            //self.secondLabel.text = "On"
            self.stateSwitch.onTintColor = .green
        }
        
        if(self.state_armed == false){
            self.stateColor.backgroundColor = .red
            self.imageState.image = UIImage(named: "open-lock")
            
            self.firstLabel.text = "The system is DISARMED"
            //self.secondLabel.text = "Off"
            self.stateSwitch.onTintColor = .red
        }
        //}
    }
    
    func initializeAlarm() {
        sirenImage.image =  UIImage(named: "siren")
        sirenLabel.text = "Siren"
    }
}

class AlarmTableViewCell: UITableViewCell {
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator){
        super.didUpdateFocus(in: context, with: coordinator)
    }
}
