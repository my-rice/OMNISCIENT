import UIKit
import CoreData

class HomeController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var HomeTableView: UITableView!
    @IBOutlet var HomeView: UIView!

    let context = PersistanceController.shared.container.viewContext
    var roomList: [Room] {
        let fetchRequest = Room.fetchRequest()
        let rooms = try! context.fetch(fetchRequest)
        print("roomList requested")
        return rooms
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        // Do any additional setup after loading the view.
        self.HomeTableView.separatorStyle = UITableViewCell.SeparatorStyle.none //Toglie il separatore (divider)
        self.HomeTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        HomeTableView.dataSource = self
        HomeTableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.staticDataUpdated, object: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        HomeTableView.refreshControl = refreshControl
    }
    
    //Definisco il numero di sezioni
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Definisco il numero di celle per sezione
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomList.count
    }
    
    //Funzione chiamata prima del segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let roomController = segue.destination as? RoomController, let roomTableCell = sender as? RoomTableCell{
            //roomController.room = roomTableCell.room
            roomController.roomName = roomTableCell.room?.name!
            roomController.setTitle(title: roomTableCell.room?.name ?? "")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RoomTableCell = self.HomeTableView.dequeueReusableCell(withIdentifier: "RoomIdentifier", for: indexPath) as! RoomTableCell
        
        //Inizializza le celle della tableView
        let room = roomList[indexPath.row]
        cell.initialize(room: room)
        return cell
    }
    
    @objc func contextObjectsDidChange(_:Any){
        print("Home Controller: context changed")
        DispatchQueue.main.async {
            self.HomeTableView.reloadData()
        }
    }
    
    @objc func refresh(refreshControl: UIRefreshControl){
        PersistanceController.fetchStaticContent(context: context)
        refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentDeletionFailsafe(indexPath: indexPath)
        }
    }
    
    func presentDeletionFailsafe(indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "Are you sure you'd like to delete this cell", preferredStyle: .alert)
        let deletedRoom = roomList[indexPath.row]
        // yes action
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            APIHelper.deleteRoom(roomName: deletedRoom.name!){
                result in
                switch(result){
                case .success(let s):
                    self.context.delete(deletedRoom)
                    try! self.context.save()
                    NotificationCenter.default.post(name: NSNotification.Name.staticDataUpdated, object: nil)
                case .failure(let e):
                    print("Error",e)
                }
            }
        }
        alert.addAction(yesAction)
        // cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}


class RoomTableCell: UITableViewCell {
    @IBOutlet weak var roomTitle: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellImageView: UIImageView!
    
    var room: Room?
    func initialize(room: Room) {
        //Qui viene definito il template delle celle
        cellView.layer.cornerRadius = 20
        cellImageView.layer.cornerRadius = 20
        self.room=room
        //Prelevare i dati da CoreData
        self.setRoomTitle(roomTitle: room.name!)
        
        if( room.hasImage == false ){
            self.removeBackgroundImage()
            self.setBackgroundColor(color:
                                        UIColor(red: CGFloat(room.colorRed),
                                                green: CGFloat(room.colorGreen),
                                                blue: CGFloat(room.colorBlue),
                                                alpha: CGFloat(room.colorAlpha))
                                    )
            print(room)
        }else {
            
            self.setBackgroundImage(image: UIImage(ciImage: CIImage(data: room.image!)!, scale: 1.0 , orientation: .up ))
        }
    }
    
    //Personalizzazione delle celle
    public func setRoomTitle(roomTitle: String){
        self.roomTitle.text = roomTitle
    }
    public func setBackgroundColor(color: UIColor){
        cellView.backgroundColor = color
    }
    public func setBackgroundImage(image: UIImage){
        cellImageView.image = image
    }
    public func removeBackgroundImage(){
        cellImageView.image = nil
    }
    
}
