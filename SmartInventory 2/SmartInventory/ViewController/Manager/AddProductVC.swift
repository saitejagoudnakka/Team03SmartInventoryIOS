
import UIKit

class AddProductVC: BaseVC,UIPickerViewDelegate, UIPickerViewDataSource  {
    @IBOutlet weak var categoryTxt: UITextField!
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var upcTxt: UITextField!
    @IBOutlet weak var quantityTxt: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!

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
    }
    
    @IBAction func onCategory(_ sender: Any) {
        self.showPicker()
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if validate(){
            let randomWarehouseID = generateRandomWarehouseID()
            self.updateProductData(data: ProductModel(productname: self.productNameTxt.text ?? "", warehouseID: "\(randomWarehouseID)", upcNumber: self.productNameTxt.text ?? "", quantity: self.productNameTxt.text ?? "", category: self.productNameTxt.text ?? ""))
        }
    }
    
    func generateRandomWarehouseID() -> Int {
        let warehouseID = Int.random(in: 1000...9999)
        return warehouseID
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
            return productCategories.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return productCategories[row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let selectedCategory = productCategories[row]
            categoryTxt.text = selectedCategory.capitalized
            pickerView.isHidden = true
        }

}


extension AddProductVC {
    func updateProductData(data: ProductModel){
        
        FireStoreManager.shared.addProductDetail(documentID: UserDefaultsManager.shared.getDocumentId(), email: UserDefaultsManager.shared.getEmail(), data: data) { success in
            if success{
                showOkAlertAnyWhereWithCallBack(message: "Product added successfully") {
                        self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
        }
}
