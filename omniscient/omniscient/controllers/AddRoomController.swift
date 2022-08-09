import Foundation
import UIKit


class AddRoomController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate ,UIColorPickerViewControllerDelegate {
    

    @IBOutlet weak var nameRoomTextField: UITextField!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var selectedColor: UIColor = UIColor(red: CGFloat(0.5), green: CGFloat(0.5), blue: CGFloat(0.5), alpha: CGFloat(1))
    var isImage = false

    let context = PersistanceController.shared.container.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("IndexPath section: \(indexPath.section) IndexPath row:  \(indexPath.row)")
        
        if(indexPath.section == 1 && indexPath.row == 0){
            
            let ac = UIAlertController(title: "Select Image", message: "Select image from: ", preferredStyle: .actionSheet)
            
            let cameraBtn = UIAlertAction(title: "Camera", style: .default){ (_) in
                print("Camera Press")
                self.showImagePicker(selectedSource: .camera)
            }
            let libraryBtn = UIAlertAction(title: "Library", style: .default){ (_) in
                print("Library Press")
                self.showImagePicker(selectedSource: .photoLibrary) //Sarà deprecato
            }
            let colorBtn = UIAlertAction(title: "Select Color", style: .default){ (_) in
                print("Color Press")
                self.showColorPicker()
            }
            let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            ac.addAction(cameraBtn)
            ac.addAction(libraryBtn)
            ac.addAction(colorBtn)
            ac.addAction(cancelBtn)
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    
    func showImagePicker(selectedSource: UIImagePickerController.SourceType){
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else{
            print("Immagine non disponibile")
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSource
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage{
            backgroundImage.image = selectedImage
            isImage = true
        } else {
            print("Immagine non trovata")
            isImage = false
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showColorPicker(){
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        colorPickerVC.isModalInPresentation = true //Non si può swipare questa schermata
        present(colorPickerVC, animated: true)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        backgroundImage.image = UIImage(color: selectedColor)
        isImage = false
    }

    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let roomName = getNameRoomTextField()
        if roomName == "" {
            let alert = UIAlertController(title: nil, message: "You must insert a room name", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        let ciColor = CIColor(color: selectedColor)
        let pngImageData = backgroundImage.image?.pngData()
        
        APIHelper.createRoom(roomName: roomName,color: ciColor){
            result in
            switch(result){
            case(.success(let s)):
                let room = Room(context:self.context)
                room.name=roomName
                room.colorRed=Float(ciColor.red)
                room.colorGreen=Float(ciColor.green)
                room.colorBlue=Float(ciColor.blue)
                room.colorAlpha=Float(ciColor.alpha)
                
                room.hasImage=self.isImage
                if (self.isImage) {
                    room.image = pngImageData
                }
                
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

    func getNameRoomTextField() -> String {
        return nameRoomTextField.text ?? ""
    }
    
}


public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
      }
}
