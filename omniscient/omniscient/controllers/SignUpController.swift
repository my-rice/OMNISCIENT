import Foundation
import UIKit

class SignUpController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func onSignup(_ sender: Any) {
        let username = usernameTextField.text
        let password = passwordTextField.text
        let email = emailTextField.text
        let emailPattern = #"^\S+@\S+\.\S+$"#
        if (username?.isEmpty ?? true) || (password?.isEmpty ?? true) || (email?.isEmpty ?? true) {
            let alert = UIAlertController(title: "Error", message: "Invalid credentials!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if(email!.range(of: emailPattern,options: .regularExpression) == nil){
            let alert = UIAlertController(title: "Error", message: "Invalid email!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true, completion: nil)
            return
        }
        APIHelper.signup(username: username!, email: email!, password: password!){
            result in
            switch(result){
            case(.success(_)):
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Signed up succesfully!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel){_ in
                        self.presentingViewController?.dismiss(animated: true)
                    })
                    self.present(alert, animated: true, completion: nil)
                }
            case(.failure(let e)):
                print(e)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Username already exists!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
        }
    }
}
