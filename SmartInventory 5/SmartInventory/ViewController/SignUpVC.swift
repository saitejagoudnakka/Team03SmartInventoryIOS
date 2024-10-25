//

import UIKit

class SignUpVC: BaseVC {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!

    var userType = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        if validate(){
            FireStoreManager.shared.signUp(email: self.email.text?.lowercased() ?? "", password: self.password.text ?? "", userType: userType)
        }
        
    }

    @IBAction func onLogin(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    
    func validate() ->Bool {
        
        if(self.email.text!.isEmpty) {
             showAlerOnTop(message: "Please enter email.")
            return false
        }
        
        if !email.text!.emailIsCorrect() {
            showAlerOnTop(message: "Please enter valid email id")
            return false
        }
        
        if(self.password.text!.isEmpty) {
             showAlerOnTop(message: "Please enter password.")
            return false
        }
        
        if !(self.password.text ?? "").isValidPassword() {
            showAlerOnTop(message: "Password must be at least 8 characters long and Password must contain at least one special character.")
            return false
        }
        
        if(self.confirmPassword.text!.isEmpty) {
             showAlerOnTop(message: "Please enter confirm password.")
            return false
        }
        
           if(self.password.text! != self.confirmPassword.text!) {
             showAlerOnTop(message: "Password doesn't match")
            return false
        }
        
        if(self.password.text!.count < 5 || self.password.text!.count > 10 ) {
            
             showAlerOnTop(message: "Password  length shoud be 5 to 10")
            return false
        }
        
        
        return true
    }

    
    @IBAction func onShowHidePassword(_ sender: UIButton) {
        
        if(sender.tag == 1) {
            let buttonImageName = password.isSecureTextEntry ? "eye" : "eye.slash"
            if let buttonImage = UIImage(systemName: buttonImageName) {
                sender.setImage(buttonImage, for: .normal)
            }
            self.password.isSecureTextEntry.toggle()
        }
        
        if(sender.tag == 2) {
            let buttonImageName = confirmPassword.isSecureTextEntry ? "eye" : "eye.slash"
            if let buttonImage = UIImage(systemName: buttonImageName) {
                sender.setImage(buttonImage, for: .normal)
            }
            self.confirmPassword.isSecureTextEntry.toggle()
        }
    }
}



