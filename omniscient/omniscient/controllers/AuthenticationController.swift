import Foundation

class AuthenticationController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loginImage: UIImageView!
    override func viewDidLoad() {
        loginImage.image = UIImage(named: "hanso")
        usernameTextField.autocorrectionType = .no
        passwordTextField.autocorrectionType = .no
        usernameTextField.autocapitalizationType = .none
        passwordTextField.autocapitalizationType = .none
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        if (username?.isEmpty ?? true) || (password?.isEmpty ?? true) {
            let alert = UIAlertController(title: "Error", message: "Invalid credentials!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true, completion: nil)
            return
        }
        APIHelper.login(username: username!, password: password!){
            result in
            switch(result){
            case(.success(let s)):
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(s.accessToken, forKey: "authToken")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name.login, object: nil) //Mostra la schermata principale dell'applicazione
                }
            case(.failure(let e)):
                print(e)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Wrong username or password!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
        }
    }
    
}
