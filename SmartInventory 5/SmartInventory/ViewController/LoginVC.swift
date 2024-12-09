//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginVC: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onLogin(_ sender: Any) {
        if(email.text!.isEmpty) {
            showAlerOnTop(message: "Please enter your email id.")
            return
        }
        
        if (self.password.text!.isEmpty) {
            showAlerOnTop(message: "Please enter your password.")
            return
            
        } else if !(self.password.text ?? "").isValidPassword() {
            showAlerOnTop(message: "Password must be at least 8 characters long and Password must contain at least one special character.")
            return
        }
        else{
            // Sign in with an existing user
            FireStoreManager.shared.login(email: email.text?.lowercased() ?? "", password: password.text ?? "") { success in
                if success{
                    let userType = UserDefaultsManager.shared.getUserType()
                    print("userType",userType)
                    SceneDelegate.shared?.loginCheckOrRestart()
                }
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "InitialVC" ) as! InitialVC
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onForgotPassword(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "ForgotPassword" ) as! ForgotPassword
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onShowHidePassword(_ sender: UIButton) {
        
        let buttonImageName = password.isSecureTextEntry ? "eye" : "eye.slash"
        if let buttonImage = UIImage(systemName: buttonImageName) {
            sender.setImage(buttonImage, for: .normal)
        }
        
        self.password.isSecureTextEntry.toggle()
        
    }
}

extension String {
    func isValidPassword() -> Bool {
        let passwordRegex = "^(?=.*[!@#$&*])(?=.*[A-Za-z]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
}

