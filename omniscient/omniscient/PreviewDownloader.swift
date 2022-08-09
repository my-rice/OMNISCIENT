import Foundation
import UIKit
class PreviewDownloader: NSObject,VLCMediaPlayerDelegate{
    let player: VLCMediaPlayer = VLCMediaPlayer(options: ["--rtsp-tcp","-vvvv"])
    let  urlString: String
    let semaphore = DispatchSemaphore(value: 0)
    var image: UIImage?
    var view: UIView
    var id: String
    
    init(urlToDownload urlString: String,view: UIView,id: String){
        self.id=id
        self.view=view
        self.urlString = urlString
        super.init()
        player.delegate = self
        player.drawable = view
    }
    
    func download() -> UIImage?{
        let url = URL(string: urlString)
        if url == nil {
            print("Invalid URL")
            return nil
        }
        let media = VLCMedia(url: url!)
        player.media=media
        player.play()
        print("Starting to wait")
        
        semaphore.wait()
        print("Resumed")
        player.stop()
        return image
    }
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        //print("TIME CHANGED: ", aNotification!)
        print(player.hasVideoOut)
        if(player.hasVideoOut){
            print("Snapshot taken")
            
            let tmpDirURL = FileManager.default.temporaryDirectory
            let path = tmpDirURL.appendingPathComponent("snapshot"+id)
            
            player.saveVideoSnapshot(at: path.path, withWidth: 0, andHeight: 0)
            
            image=UIImage(contentsOfFile: path.path)
            semaphore.signal()
        }
    }
}
