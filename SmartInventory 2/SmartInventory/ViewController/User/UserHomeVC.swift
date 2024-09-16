
enum UserType : String {
    case manager = "Manager"
    case user = "User"
}


import UIKit
class UserHomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        showLogoutAlert()
    }

    func showLogoutAlert() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.handleLogout()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(logoutAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func handleLogout() {
        UserDefaultsManager.shared.clearData()
        SceneDelegate.shared!.loginCheckOrRestart()
    }
}
