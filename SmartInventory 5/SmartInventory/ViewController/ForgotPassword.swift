//
//  ForgotPassword.swift
//  Online Diagnosis
//
//

import UIKit

class ForgotPassword: BaseVC {
    @IBOutlet weak var email: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onSend(_ sender: Any) {
        if(email.text!.isEmpty) {
            showAlerOnTop(message: "Please enter your email id.")
            return
        }
        else{
            FireStoreManager.shared.getPassword(email: self.email.text!.lowercased(), password: "") { password in
                
                FireStoreManager.shared.sendEmail(to: self.email.text!.lowercased(), password: password)
//                let vc = self.storyboard?.instantiateViewController(withIdentifier:  "ChangePasswordVC" ) as! ChangePasswordVC
//                        
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    
}
