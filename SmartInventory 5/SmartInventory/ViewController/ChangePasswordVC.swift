//
//  ChangePasswordVC.swift
//  SmartInventory
//
//  Created by Macbook-Pro on 12/09/24.
//

import UIKit

class ChangePasswordVC: BaseVC {
    @IBOutlet weak var newpassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onChangePassword(_ sender: Any) {
        if validate(){
            let documentid = UserDefaults.standard.string(forKey: "documentId") ?? ""
            let userdata = ["password": self.newpassword.text ?? ""]
            FireStoreManager.shared.changePassword(documentid: documentid, userData: userdata) { success in
                if success {
                    showOkAlertAnyWhereWithCallBack(message: "Password Updated Successfully") {
                        
                        DispatchQueue.main.async {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                        
                    }
                }
            }
        }
    }
    
    func validate() ->Bool {
        
        if(self.newpassword.text!.isEmpty) {
            showAlerOnTop(message: "Please enter new password.")
            return false
        }
        if(self.confirmPassword.text!.isEmpty) {
            showAlerOnTop(message: "Please enter confirm password.")
            return false
        }
        
        if(self.newpassword.text! != self.confirmPassword.text!) {
            showAlerOnTop(message: "Password doesn't match")
            return false
        }
        
        
        return true
    }
    
    
    @IBAction func onShowHidePassword(_ sender: UIButton) {
        
        if(sender.tag == 1) {
            let buttonImageName = newpassword.isSecureTextEntry ? "eye" : "eye.slash"
            if let buttonImage = UIImage(systemName: buttonImageName) {
                sender.setImage(buttonImage, for: .normal)
            }
            self.newpassword.isSecureTextEntry.toggle()
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
