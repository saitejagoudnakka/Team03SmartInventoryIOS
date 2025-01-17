
import UIKit

class AddProductVC: BaseVC,UIPickerViewDelegate, UIPickerViewDataSource  {
    @IBOutlet weak var categoryTxt: UITextField!
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var upcTxt: UITextField!
    @IBOutlet weak var quantityTxt: UITextField!
    @IBOutlet weak var warehouseidTxt: UITextField!
    @IBOutlet weak var trackingNumberTxt: UITextField!
    @IBOutlet weak var userIdTxt: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var warehouseId = [String]()

    var pickerBool = true
    
    let productCategories = [
          "Electronics & Gadgets",
          "Home Appliances",
          "Fashion & Apparel",
          "Groceries & Essentials",
          "Health & Wellness",
          "Beauty & Personal Care",
          "Sports & Fitness",
          "Automotive & Accessories"
      ]
          
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        self.fetchWarehouseId()
    }
    
    @IBAction func onCategory(_ sender: Any) {
        self.pickerBool = true
        self.pickerView.reloadAllComponents()
        self.showPicker()
    }
    
    
    @IBAction func onwarehouse(_ sender: Any) {
        self.pickerBool = false
        self.pickerView.reloadAllComponents()
        self.showPicker()
    }
    
    
    func fetchWarehouseId() {
        FireStoreManager.shared.getWarehouseDocumentIDs { documentIDs in
            if let documentIDs = documentIDs {
                print("Document IDs: \(documentIDs)")
                self.warehouseId = documentIDs
            } else {
                print("Failed to fetch document IDs")
            }
        }
      }
    
    
    @IBAction func onSubmit(_ sender: Any) {
        if validate(){
            let price = AddProductVC.getRandomPrice(min: 100.0, max: 500.0)
            let productPriceString = String(format: "$%.2f", price)
            self.updateProductData(data: RequestModel(productname: self.productNameTxt.text ?? "", warehouseID: UserDefaultsManager.shared.getUserWarehouseId(), upcNumber: self.upcTxt.text ?? "", quantity: self.quantityTxt.text ?? "", shippingFile: "", userid: self.userIdTxt.text ?? "", managerid: UserDefaultsManager.shared.getDocumentId(), requestId: "", category: self.categoryTxt.text ?? "", availableQuantity: self.quantityTxt.text ?? "", managerEmail: UserDefaultsManager.shared.getEmail(), userEmail: "", price: productPriceString, paymentStatus: "pending", trackingNumber: self.trackingNumberTxt.text ?? "", status_accepted_rejected: "", packageStatus: "", added_time: Int(Date().timeIntervalSince1970), approved_time: 0))
        }
    }
    
   static func getRandomPrice(min: Double, max: Double) -> Double {
        let randomPrice = Double.random(in: min...max)
        return randomPrice
    }

    func validate() ->Bool {
        if(self.upcTxt.text!.isEmpty) {
             showAlerOnTop(message: "Please enter UPC number")
            return false
        }
        if(self.productNameTxt.text!.isEmpty) {
             showAlerOnTop(message: "Please enter Product name.")
            return false
        }
        if(self.userIdTxt.text!.isEmpty) {
            showAlerOnTop(message: "Please enter User Id")
           return false
       }
        if(self.trackingNumberTxt.text!.isEmpty) {
            showAlerOnTop(message: "Please enter Tracking Number")
           return false
       }
        if(self.quantityTxt.text!.isEmpty) {
            showAlerOnTop(message: "Please enter Quantity")
           return false
       } 
        if !isValidInteger(self.quantityTxt.text ?? ""){
            showAlerOnTop(message: "Please enter valid Quantity")
           return false
        }
        
        if(self.categoryTxt.text!.isEmpty) {
           showAlerOnTop(message: "Please select Category")
          return false
      }
        
        return true
    }
    
    func isValidInteger(_ input: String) -> Bool {
        return Int(input) != nil
    }
    
    
     func showPicker() {
            pickerView.isHidden = !pickerView.isHidden
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerBool{
                return productCategories.count
            } else {
                return warehouseId.count
            }
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if pickerBool{
                return productCategories[row]
            } else {
                return warehouseId[row]
            }
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            if pickerBool{
                let selectedCategory = productCategories[row]
                categoryTxt.text = selectedCategory.capitalized
                pickerView.isHidden = true
            } else {
                let selectedCategory = warehouseId[row]
                warehouseidTxt.text = selectedCategory
                pickerView.isHidden = true
            }
        }

}


extension AddProductVC {
    func updateProductData(data: RequestModel){
        FireStoreManager.shared.addProductDetail(wareHouseId: UserDefaultsManager.shared.getUserWarehouseId(), product: data) { success in
            if success{
                showOkAlertAnyWhereWithCallBack(message: "Product added successfully") {
                        self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        }
}
