//
//  ResetPasswordVC.swift
//  Smart Inventory
//
//  Created by Harini Beeram on 5/21/24.
//


import UIKit
import FirebaseAuth

class ResetPasswordVC: UIViewController {

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
                            self.showAlert(message: "Reset email sent successfully.")
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

   
