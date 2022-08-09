import Foundation

struct AppUtility {

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask = .portrait) {
    
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask = .portrait, andRotateTo rotateOrientation:UIInterfaceOrientation = .portrait) {
   
        self.lockOrientation(orientation)
    
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }

}
