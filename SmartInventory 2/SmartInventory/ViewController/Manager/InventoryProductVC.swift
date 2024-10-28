

import UIKit

class InventoryProductVC: BaseVC,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var productsRequest: [RequestModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.fetchProductData()
    }

    func fetchProductData() {
        FireStoreManager.shared.getAllAcceptedProductRecord(forUserId: UserDefaultsManager.shared.getDocumentId()) { [weak self] fetchedProducts, error in
              if let error = error {
                  print("Error fetching products: \(error.localizedDescription)")
              } else if let fetchedProducts = fetchedProducts {
                  self?.productsRequest = fetchedProducts
                  self?.tableView.reloadData()
              }
          }
      }
    
}


extension InventoryProductVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productsRequest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: TableViewCell.self), for: indexPath) as! TableViewCell
       
        let data = self.productsRequest[indexPath.row]
        cell.productName.text = "Product Name: \(data.productname ?? "")"
        cell.quantity.text = "Quantity: \(data.quantity ?? "")"
        cell.upcNumber.text = "UPC number: \(data.upcNumber ?? "")"
        cell.userid.text = "User Id: \(data.userid ?? "")"
        
        cell.acceptBtn.tag = indexPath.row
        cell.acceptBtn.addTarget(self, action: #selector(self.acceptAppointmentStatus(_:)), for: .touchUpInside)

        
        return cell
    }
    
    @objc func acceptAppointmentStatus(_ sender: UIButton) {
        
        let data = productsRequest[sender.tag]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.chatID = getChatID(email1: data.managerEmail ?? "", email2: data.userEmail ?? "")
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
        vc.productRecord = productsRequest[indexPath.row]
        vc.showPayBtn = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
