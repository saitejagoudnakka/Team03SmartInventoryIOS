
import UIKit

class AddProductVC: BaseVC,UIPickerViewDelegate, UIPickerViewDataSource  {
    @IBOutlet weak var categoryTxt: UITextField!
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var upcTxt: UITextField!
    @IBOutlet weak var quantityTxt: UITextField!
    @IBOutlet weak var warehouseidTxt: UITextField!
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
            self.updateProductData(data: RequestModel(productname: self.productNameTxt.text ?? "", warehouseID: self.warehouseidTxt.text ?? "", upcNumber: self.upcTxt.text ?? "", quantity: self.quantityTxt.text ?? "", shippingFile: "", userid: "", managerid: UserDefaultsManager.shared.getDocumentId(), requestId: "", category: self.categoryTxt.text ?? "", availableQuantity: self.quantityTxt.text ?? "", managerEmail: UserDefaultsManager.shared.getEmail(), userEmail: ""))
        }
    }
    

    func validate() ->Bool {
        
        if(self.productNameTxt.text!.isEmpty) {
             showAlerOnTop(message: "Please enter Product name.")
            return false
        }
        if(self.upcTxt.text!.isEmpty) {
             showAlerOnTop(message: "Please enter UPC number")
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
        FireStoreManager.shared.addProductDetail(wareHouseId: self.warehouseidTxt.text ?? "", product: data) { success in
            if success{
                showOkAlertAnyWhereWithCallBack(message: "Product added successfully") {
                        self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        }
}
