
import UIKit

class InventoryListVC: BaseVC,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var products: [RequestModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        FireStoreManager.shared.getAllWarehouseProducts { [weak self] productsArray in
                guard let self = self else { return }
                if let productsArray = productsArray {
                    self.products = productsArray
                    self.tableView.reloadData()
                }
            }
    }

}


extension InventoryListVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: TableViewCell.self), for: indexPath) as! TableViewCell
        let data = self.products[indexPath.row]
        cell.productName.text = "Product Name: \(data.productname ?? "")"
        cell.quantity.text = "Quantity: \(data.quantity ?? "")"
        cell.upcNumber.text = "UPC number: \(data.upcNumber ?? "")"
        cell.userid.text = "Warehouse Id: \(data.warehouseID ?? "")"
        
        cell.acceptBtn.tag = indexPath.row
        cell.acceptBtn.addTarget(self, action: #selector(openRaiseRequest(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    @objc func openRaiseRequest(_ sender: UIButton) {
        let data = self.products[sender.tag]
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier:  "RequestVC" ) as! RequestVC
        vc.productData = data
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
   
}
