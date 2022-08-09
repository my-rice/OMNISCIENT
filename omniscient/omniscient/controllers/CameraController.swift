import Foundation
import UIKit

class CameraController: UIViewController,VLCMediaPlayerDelegate,VLCMediaThumbnailerDelegate{
    func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
        print("Thumbnailer timed out")
    }
    func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer!, didFinishThumbnail thumbnail: CGImage!) {
        image.image=UIImage(cgImage: thumbnail)
    }
    
    @IBOutlet weak var movieView: UIView!

    @IBOutlet weak var image: UIImageView!
    //Enable debugging
    //var mediaPlayer: VLCMediaPlayer = VLCMediaPlayer(options: ["-vvvv"])
    var mediaPlayer: VLCMediaPlayer?
    //var mediaThumbnailer: VLCMediaThumbnailer?
    var hasTakenSnapshot: Bool = false
    var camera: Camera?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mediaPlayer = VLCMediaPlayer(options: ["--rtsp-tcp"]) //NOTA:  --rtsp-tcp forza l'uso di tcp. Questo permette di risolvere un bug relativo all'assenza di ack da parte del client che comportava la chiusura della connesisone rtsp dopo circa 30 secondi a causa della scadenza del timeout. Potrebbe non essere necessario per alcuni modelli di telecamere. NON rimuovere!
        //mediaPlayer!.libraryInstance.debugLogging = true
        //mediaPlayer!.libraryInstance.debugLoggingLevel = 3
        self.movieView.backgroundColor = UIColor.gray

        let gesture = UITapGestureRecognizer(target: self, action: #selector(CameraController.movieViewTapped(_:)))
        self.movieView.addGestureRecognizer(gesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        //let url = NSURL(string: "udp://@225.0.0.1:51018")
        //let url = NSURL(string: "http://streams.videolan.org/streams/mp4/Mr_MrsSmith-h264_aac.mp4")
        //let url = URL(string: "rtsp://admin:password@192.168.1.74:554/live/ch0")
        //let url = URL(string: "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mp4")
        let url = URL(string: "rtsp://\(camera!.username!):\(camera!.password!)@\(camera!.domain!):\(camera!.port!)")
        if url == nil {
            print("Invalid URL")
            return
        }

        let media = VLCMedia(url: url!)
        mediaPlayer!.media = media

        mediaPlayer!.delegate = self
        mediaPlayer!.drawable = self.movieView
        //mediaThumbnailer = VLCMediaThumbnailer(media: media, andDelegate: self)
        //mediaThumbnailer!.fetchThumbnail()
        mediaPlayer?.play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        mediaPlayer!.stop()
        //print("Will disappear")
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    override func didReceiveMemoryWarning() {
        //print("WARNING!!!!!!")
        super.didReceiveMemoryWarning()
    }
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        print("STATE CHANGED: ", aNotification!)
    }
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        
    }
    @objc func rotated() {

        let orientation = UIDevice.current.orientation

        if (orientation.isLandscape) {
            print("Switched to landscape")
        }
        else if(orientation.isPortrait) {
            print("Switched to portrait")
        }
        self.movieView.frame = self.view.frame
    }

    @objc func movieViewTapped(_ sender: UITapGestureRecognizer) {
        if mediaPlayer!.isPlaying {
            mediaPlayer!.pause()
            let remaining = mediaPlayer!.remainingTime
            let time = mediaPlayer!.time
            //print("Paused at \(time?.stringValue ?? "nil") with \(remaining?.stringValue ?? "nil") time remaining")
        }
        else {
            mediaPlayer!.play()
            //print("Playing")
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)
   }
}
