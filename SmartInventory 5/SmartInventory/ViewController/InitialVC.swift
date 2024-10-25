//

import UIKit
import LocalAuthentication

class InitialVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onManager(_ sender: Any)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "SignUpVC" ) as! SignUpVC
        vc.userType = "Manager"
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    @IBAction func onUser(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "SignUpVC" ) as! SignUpVC
        vc.userType = "User"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

