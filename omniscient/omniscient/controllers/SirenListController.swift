import Foundation
import UIKit

class SirenListController: UITableViewController {
    let context = PersistanceController.shared.container.viewContext
    var sirenList: [Actuator] {
        let fetchRequest = Actuator.fetchRequest()
        //fetchRequest.predicate = NSPredicate(format: "type == 'BUZZER'")
        let sirens = try! context.fetch(fetchRequest)
        print("sirens fetched",sirens)
        return sirens
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sirens"
        view.backgroundColor = .systemGray6
        // Do any additional setup after loading the view.
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none //Toglie il separatore (divider)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.staticDataUpdated, object: nil)
        
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = rc
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 4.0
        }
    
    //Definisco il numero di sezioni
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sirenList.count
    }
    
    //Definisco il numero di celle per sezione
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SirenListTableCell = tableView.dequeueReusableCell(withIdentifier: "SirenIdentifier", for: indexPath) as! SirenListTableCell
        
        //Inizializza le celle della tableView
        let siren = sirenList[indexPath.section]
        cell.initialize(siren: siren)
        return cell
    }
    
    @objc func contextObjectsDidChange(_:Any){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func refresh(refreshControl: UIRefreshControl){
        PersistanceController.fetchStaticContent(context: context)
        refreshControl.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            let siren = sirenList[indexPath.section]
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
                // Crea le azioni da fare
                let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                            // CANCELLAZIONE
                    print("Delete cell at \(indexPath)")
                    APIHelper.deleteSiren(sirenID: siren.remoteID!){
                        result in
                        switch(result){
                        case .success(_):
                            DispatchQueue.main.async {
                                (self.tableView.cellForRow(at: indexPath) as! SirenListTableCell).prepareForReuse()
                                self.context.delete(siren)
                                try! self.context.save()
                                self.tableView.reloadData()
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
    
}


class SirenListTableCell: UITableViewCell {
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var label: UILabel!
    
    func initialize(siren: Actuator){
        subView.layer.cornerRadius = 12
        label.text = siren.name!
    }
    override func prepareForReuse() {
        subView.superview!.backgroundColor = .systemGray6
    }
}
