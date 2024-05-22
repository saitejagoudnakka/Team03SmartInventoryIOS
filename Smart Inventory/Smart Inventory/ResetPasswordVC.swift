//
//  ResetPasswordVC.swift
//  Smart Inventory
//
//  Created by Harini Beeram on 5/21/24.
//


import UIKit
import FirebaseAuth

class ResetPasswordVC: UIViewController {
    
    override func viewDidLoad() {
           super.viewDidLoad()
           self.view.backgroundColor = UIColor.systemGray6
       }
        
        
        
        
        
        @IBOutlet weak var email: UITextField!
        
        
        
        @IBAction func onSend(_ sender: UIButton) {
            
            guard let email = email.text, !email.isEmpty else {
                        showAlert(message: "Please enter your email address.")
                        return
                    }
                    
                    Auth.auth().sendPasswordReset(withEmail: email) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                self.showAlert(message: "Error resetting password: \(error.localizedDescription)")
                            } else {
                                self.showAlert(message: "A password reset email has been sent to \(email). Please check your inbox and follow the instructions to reset your password.")
                                //self.performSegue(withIdentifier: "resettologinSegue", sender: nil)
                            }
                        }
                    }
           
        }
                
                private func showAlert(message: String) {
                    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    present(alert, animated: true, completion: nil)
                }
            }

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
