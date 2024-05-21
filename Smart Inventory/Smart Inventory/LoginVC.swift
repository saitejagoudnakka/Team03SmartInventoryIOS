//
//  LoginVC.swift
//  Smart Inventory
//
//  Created by Harini Beeram on 5/21/24.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    //var animatedGradient: AnimatedGradientView!
    var rememberMe: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set placeholder text
        email.placeholder = "Enter your email"
        password.placeholder = "Enter your password"
        password.isSecureTextEntry = true // Secure password input
        
        // Any additional setup can go here
    }
    
    //    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    //        super.viewWillTransition(to: size, with: coordinator)
    //
    //        // Update the frame of the animated gradient view when the device rotates
    //        coordinator.animate(alongsideTransition: { _ in
    //            self.animatedGradient?.frame = CGRect(origin: CGPoint.zero, size: size)
    //        }, completion: nil)
    //    }
    
    
    
    @IBAction func onLogin(_ sender: Any) {
        guard let email = email.text, !email.isEmpty,
                      let password = password.text, !password.isEmpty else {
                    showAlert(message: "Please fill in all fields.")
                    return
                }

                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        self.showAlert(message: "Error: \(error.localizedDescription)")
                    } else {
                        self.performSegue(withIdentifier: "loginSuccessSegue", sender: nil)
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


