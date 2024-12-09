//
//  PaymentListVC.swift
//  SmartInventory
//
//  Created by Macbook-Pro on 27/09/24.
//

import UIKit

class PaymentListVC: BaseVC,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var products: [RequestModel] = []
    var isManager = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if isManager {
            FireStoreManager.shared.getReceivedPaymentProductsForManager(forManagerId: UserDefaultsManager.shared.getDocumentId()) { fetchedProducts, error in
                if let error = error {
                    print("Error fetching products: \(error.localizedDescription)")
                } else if let fetchedProducts = fetchedProducts {
                    self.products = fetchedProducts
                    self.tableView.reloadData()
                }
            }
        } else {
            FireStoreManager.shared.getAcceptedProductsWithSuccessPayment(forUserId: UserDefaultsManager.shared.getDocumentId()) { [weak self] fetchedProducts, error in
                if let error = error {
                    print("Error fetching products: \(error.localizedDescription)")
                } else if let fetchedProducts = fetchedProducts {
                    self?.products = fetchedProducts
                    self?.tableView.reloadData()
                }
            }
        }
    }
}


extension PaymentListVC {
    
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
        cell.price.text = "Price: " + (data.price ?? "")
        cell.userid.text = isManager ? "Payment Received" : "Payment Success"
        cell.useridum.text = isManager ? ("User Id: \(data.userid ?? "")") : ("Manager Id: \(data.managerid ?? "")")
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
   
}
