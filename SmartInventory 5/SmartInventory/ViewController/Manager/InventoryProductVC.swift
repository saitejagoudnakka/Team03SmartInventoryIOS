

import UIKit

class InventoryProductVC: BaseVC,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    var productsRequest: [RequestModel] = []
    @IBOutlet weak var searchBar: UISearchBar!
    var isSearching = false
    var filteredProducts: [RequestModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.fetchProductData()
        setupSearchBar()

    }

    private func setupSearchBar() {
           searchBar.delegate = self
           searchBar.placeholder = "Search by product name, quantity, UPC no. or warehouse id"
           navigationItem.titleView = searchBar
       }

    
    func fetchProductData() {
        FireStoreManager.shared.getAllAcceptedProductRecord(forUserId: UserDefaultsManager.shared.getDocumentId()) { [weak self] fetchedProducts, error in
              if let error = error {
                  print("Error fetching products: \(error.localizedDescription)")
              } else if let fetchedProducts = fetchedProducts {
                  self?.productsRequest = fetchedProducts.sorted { $0.approved_time ?? 0 > $1.approved_time ?? 0}
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
        return isSearching ? filteredProducts.count : productsRequest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: TableViewCell.self), for: indexPath) as! TableViewCell
        let data = isSearching ? filteredProducts[indexPath.row] : productsRequest[indexPath.row]

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
        let data = isSearching ? filteredProducts[indexPath.row] : productsRequest[indexPath.row]

        vc.productRecord = data
        vc.showPayBtn = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           if searchText.isEmpty {
               isSearching = false
               filteredProducts = []
           } else {
               isSearching = true
               filteredProducts = productsRequest.filter { product in
                   return product.productname!.lowercased().contains(searchText.lowercased()) || product.quantity!.contains(searchText) || product.upcNumber!.contains(searchText) || product.warehouseID!.contains(searchText)
                   
               }
           }
           tableView.reloadData()
       }

       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = ""
           isSearching = false
           filteredProducts = []
           tableView.reloadData()
           searchBar.resignFirstResponder()
       }

}
