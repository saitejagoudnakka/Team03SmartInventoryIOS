//
//  CreateAccountVC.swift
//  Smart Inventory
//
//  Created by Harini Beeram on 5/21/24.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class CreateAccountVC: UIViewController {

    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       }
    
    @IBAction func onSignUp(_ sender: Any) {
        guard let firstName = firstname.text, !firstName.isEmpty,
                     let lastName = lastname.text, !lastName.isEmpty,
                     let email = email.text, !email.isEmpty,
                     let phone = phone.text, !phone.isEmpty,
                     let password = password.text, !password.isEmpty,
                     let confirmPassword = confirmPassword.text, !confirmPassword.isEmpty else {
                   showAlert(message: "Please fill in all fields.")
                   return
               }

               if password != confirmPassword {
                   showAlert(message: "Passwords do not match.")
                   return
               }

               Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                   if let error = error {
                       DispatchQueue.main.async {
                           self.showAlert(message: "Error: \(error.localizedDescription)")
                       }
                   } else {
                       // Registration successful
                       DispatchQueue.main.async {
                           self.showAlert(message: "User registered successfully!") {
                               self.navigateToLoginScreen()
                           }
                       }
                   }
               }
           }

           private func showAlert(message: String, completion: (() -> Void)? = nil) {
               let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                   completion?()
               }))
               present(alert, animated: true, completion: nil)
           }
           
           private func navigateToLoginScreen() {
               // Assuming you are using a navigation controller
               navigationController?.popViewController(animated: true)
               
               // If you are presenting modally, use:
               // self.dismiss(animated: true, completion: nil)
               
               // If you are using a segue, use:
               self.performSegue(withIdentifier: "signUpToLoginSegue", sender: nil)
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
