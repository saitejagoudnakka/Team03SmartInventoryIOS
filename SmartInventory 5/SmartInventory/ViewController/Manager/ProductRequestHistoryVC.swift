
import UIKit
import FirebaseCore

class ProductRequestHistoryVC: BaseVC,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var productsRequest: [RequestModel] = []
    var packageStatusView: PackageStatusView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.fetchProductData()
    }
    
    func fetchProductData() {
        FireStoreManager.shared.getAcceptedProductRequests(forUserId: UserDefaultsManager.shared.getDocumentId()) { [weak self] fetchedProducts, error in
            if let error = error {
                print("Error fetching accepted products: \(error.localizedDescription)")
            } else if let fetchedProducts = fetchedProducts {
                self?.productsRequest = fetchedProducts
                self?.tableView.reloadData()
            }
            
            FireStoreManager.shared.getRejectedProductRequests(forUserId: UserDefaultsManager.shared.getDocumentId()) { fetchedProducts1, error1 in
                if let error1 = error1 {
                    print("Error fetching rejected products: \(error1.localizedDescription)")
                } else if let fetchedProducts1 = fetchedProducts1 {
                    self?.productsRequest += fetchedProducts1
                    self?.tableView.reloadData()
                }
            }
        }
    }
}


extension ProductRequestHistoryVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.productsRequest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  String(describing: TableViewHistoryCell.self), for: indexPath) as! TableViewHistoryCell
        
        let data = self.productsRequest[indexPath.row]
        cell.productName.text = "Product Name: \(data.productname ?? "")"
        cell.quantity.text = "Quantity: \(data.quantity ?? "")"
        let datevalue = ProductRequestLIstVC.setDateFromTimestamp(date: data.date!)
        cell.datelbl.text = "Raised Date: \(datevalue)"
        cell.userid.text = "User Id: \(data.userid ?? "")"
        cell.status.text = "Status: \(data.status_accepted_rejected ?? "")"
        let statusTime = ProductRequestLIstVC.setDateTimeFromTimestamp(date: data.status_accepted_rejected_time ?? Date())
        cell.dateTime.text = "Request Status Time: \(statusTime)"
        
        cell.printBtn.tag = indexPath.row
        cell.printBtn.addTarget(self, action: #selector(self.printAction(_:)), for: .touchUpInside)
        
        cell.packageStatusBtn.tag = indexPath.row
        cell.lblPackageStatus.text = (data.packageStatus ?? "").isEmpty ? "Processing" : data.packageStatus
        cell.packageStatusBtn.addTarget(self, action: #selector(packageStatusButtonTapped(_:)), for: .touchUpInside)
        
        if (data.status_accepted_rejected ?? "") == "Accepted" {
            cell.viewPackageStatus.isHidden = false
        } else {
            cell.viewPackageStatus.isHidden = true
        }
        
        return cell
    }
    
    // Handle button tap
    @objc func packageStatusButtonTapped(_ sender: UIButton) {
        // Get the location of the button in the table view's coordinate system
        let buttonPosition = sender.convert(sender.bounds.origin, to: tableView)
        
        // Remove any existing custom views before adding a new one
        packageStatusView?.removeFromSuperview()
        
        // Create and add the custom view below the button
        packageStatusView = PackageStatusView()
        packageStatusView?.translatesAutoresizingMaskIntoConstraints = false
        packageStatusView?.optionSelected = { selectedStatus in
            FireStoreManager.shared.updatePackageStatus(forUserId: UserDefaultsManager.shared.getDocumentId(), requestId: self.productsRequest[sender.tag].requestId ?? "", status: selectedStatus) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        var request = self.productsRequest[sender.tag]
                        request.packageStatus = selectedStatus
                        self.tableView.reloadData()
                        showOkAlertAnyWhereWithCallBack(message: "Package Status updated successfully.") {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
            }
            print("Selected status: \(selectedStatus)")
            // Handle the selected option here (e.g., update UI or send to server)
        }
        
        guard let packageStatusView = packageStatusView else { return }
        view.addSubview(packageStatusView)
        
        // Set up constraints to position the custom view below the button
        NSLayoutConstraint.activate([
            packageStatusView.topAnchor.constraint(equalTo: tableView.topAnchor, constant: buttonPosition.y + sender.frame.height + 10),
            packageStatusView.centerXAnchor.constraint(equalTo: sender.centerXAnchor),
            packageStatusView.widthAnchor.constraint(equalToConstant: view.frame.width - 100),
            packageStatusView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func printAction(_ sender: UIButton) {
        print("printAction")
        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "Product Details"
        printController.printInfo = printInfo
        
        let data = self.productsRequest[sender.tag]
        let name = "<p style='margin-bottom: 30px;'>Product Name: \(data.productname ?? "")</p>"
        let quantity = "<p style='margin-bottom: 30px;'>Quantity: \(data.quantity ?? "")</p>"
        let datevalue = ProductRequestLIstVC.setDateFromTimestamp(date: data.date!)
        let date = "<p style='margin-bottom: 30px;'>Raised Date: \(datevalue)</p>"
        let userid = "<p style='margin-bottom: 30px;'>User Id: \(data.userid ?? "")</p>"
        let status = "<p style='margin-bottom: 30px;'>Status: \(data.status_accepted_rejected ?? "")</p>"
        let statusTime = ProductRequestLIstVC.setDateTimeFromTimestamp(date: data.status_accepted_rejected_time ?? Date())
        let statusTimef = "<p style='margin-bottom: 30px;'>Request Status Time: \(statusTime)</p>"
        let packageStatus = "<p style='margin-bottom: 30px;'>Package Status: \((data.packageStatus ?? "").isEmpty ? "Processing" : data.packageStatus ?? "")</p>"
        
        let printText = name + quantity + date + userid + status + statusTimef + packageStatus
        let formatter = UIMarkupTextPrintFormatter(markupText: "<html><body>\(printText)</body></html>")
        printController.printFormatter = formatter
        
        printController.present(animated: true, completionHandler: nil)
    }


    
    func updateAppointment(status: String, requestData: RequestModel!){
        FireStoreManager.shared.acceptProductRequest(documentid: UserDefaultsManager.shared.getDocumentId(), warehouseID: requestData.warehouseID ?? "", UPC: requestData.upcNumber ?? "", userid: requestData.userid ?? "", productName: requestData.productname ?? "", request: requestData) { success in
            if success {
                showAlerOnTop(message: "Product Accepted!!")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    func rejectUpdateAppointment(status: String, requestData: RequestModel!){
        FireStoreManager.shared.rejectProductRequest(documentid: UserDefaultsManager.shared.getDocumentId(), warehouseID: requestData.warehouseID ?? "", UPC: requestData.upcNumber ?? "", userid: requestData.userid ?? "", productName: requestData.productname ?? "", request: requestData) { success in
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


class PackageStatusView: UIView {
    
    var optionSelected: ((String) -> Void)?
    
    private let options = ["Pending", "Approved", "Rejected"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create buttons for each option
        for option in options {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            button.backgroundColor = .gray
            button.layer.cornerRadius = 5
            button.setTitleColor(.white, for: .normal)
            stackView.addArrangedSubview(button)
        }
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
        ])
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        optionSelected?(title)
        self.removeFromSuperview()  // Remove the view after selection
    }
}
