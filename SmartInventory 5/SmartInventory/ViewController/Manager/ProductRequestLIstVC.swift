
import UIKit
import FirebaseCore

class ProductRequestLIstVC: BaseVC,UITableViewDelegate, UITableViewDataSource {
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
        FireStoreManager.shared.getProductRequests(forUserId: UserDefaultsManager.shared.getDocumentId()) { [weak self] fetchedProducts, error in
              if let error = error {
                  print("Error fetching products: \(error.localizedDescription)")
              } else if let fetchedProducts = fetchedProducts {
                  self?.productsRequest = fetchedProducts
                  self?.tableView.reloadData()
              }
          }
      }
    
}


extension ProductRequestLIstVC {
    
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
        let datevalue = ProductRequestLIstVC.setDateFromTimestamp(date: data.date!)
        cell.datelbl.text = "Raised Date: \(datevalue)"
        cell.userid.text = "User Id: \(data.userid ?? "")"
        
        cell.acceptBtn.tag = indexPath.row
        cell.rejectBtn.tag = indexPath.row
        cell.acceptBtn.addTarget(self, action: #selector(self.acceptAppointmentStatus(_:)), for: .touchUpInside)
        cell.rejectBtn.addTarget(self, action: #selector(self.rejectAppointmentStatus(_:)), for: .touchUpInside)

        return cell
    }
    
    @objc func acceptAppointmentStatus(_ sender: UIButton) {
        var request = self.productsRequest[sender.tag]
        request.status_accepted_rejected = "Accepted"
        request.status_accepted_rejected_time = Date()
        self.updateAppointment(status: "Accept", requestData: request)
    }
    
    @objc func rejectAppointmentStatus(_ sender: UIButton) {
        var request = self.productsRequest[sender.tag]
        request.status_accepted_rejected = "Rejected"
        request.status_accepted_rejected_time = Date()
        self.rejectUpdateAppointment(status: "Reject", requestData: request)
    }
    
    func updateAppointment(status: String, requestData: RequestModel!) {
        
        var mutableRequestData = requestData
        mutableRequestData?.approved_time = Int(Date().timeIntervalSince1970)
        mutableRequestData?.checkOutDate = Date()

        FireStoreManager.shared.acceptProductRequest(documentid: UserDefaultsManager.shared.getDocumentId(), warehouseID: requestData.warehouseID ?? "", UPC: requestData.upcNumber ?? "", userid: requestData.userid ?? "", productName: requestData.productname ?? "" ,request: mutableRequestData!) { success in
                        if success {
                            showAlerOnTop(message: "Product Accepted!!")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
    }
    
    
    func rejectUpdateAppointment(status: String, requestData: RequestModel!) {
        
        var mutableRequestData = requestData
        mutableRequestData?.approved_time = Int(Date().timeIntervalSince1970)

        FireStoreManager.shared.rejectProductRequest(documentid: UserDefaultsManager.shared.getDocumentId(), warehouseID: requestData.warehouseID ?? "", UPC: requestData.upcNumber ?? "", userid: requestData.userid ?? "", productName: requestData.productname ?? "", request: mutableRequestData!) { success in
                        if success {
                            showAlerOnTop(message: "Product Rejected!!")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
    }
    
   static func setDateFromTimestamp(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    static func setDateTimeFromTimestamp(date: Date) -> String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateStyle = .medium
         dateFormatter.timeStyle = .short
         let dateString = dateFormatter.string(from: date)
         return dateString
     }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
