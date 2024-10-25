
import UIKit

class ManagerHomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onLogOut(_ sender: Any) {
        showLogoutAlert()
    }
    
    @IBAction func onTapPaymentHistoryBtn(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PaymentListVC") as? PaymentListVC {
            vc.isManager = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
