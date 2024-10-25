//
//  ProductDetailVC.swift
//  SmartInventory
//
//  Created by Macbook-Pro on 27/09/24.
//

import UIKit

class ProductDetailVC: BaseVC {
    @IBOutlet weak var warehouseIdTxt: UITextField!
    @IBOutlet weak var dateTxt: UITextField!
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var upcTxt: UITextField!
    @IBOutlet weak var quantityTxt: UITextField!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var payBtn: UIButton!

    var productRecord: RequestModel?
    var totalPrice = ""
    var showPayBtn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.payBtn.isHidden = true

        if showPayBtn{
            if productRecord?.paymentStatus == "pending"{
                self.payBtn.isHidden = false
                self.calculatePricePerProduct()
            } else {
                self.payBtn.isHidden = true
            }
        }
        
        self.productNameTxt.text = "Product Name: \(productRecord?.productname ?? "")"
        self.upcTxt.text = "UPC Number: \(productRecord?.upcNumber ?? "")"
        let datevalue = ProductRequestLIstVC.setDateFromTimestamp(date: (productRecord?.date)!)
        self.dateTxt.text = "Raised Date: \(datevalue)"
        self.quantityTxt.text = "Quantity: [\(productRecord?.availableQuantity ?? "")] [\(productRecord?.quantity ?? "")]"
        
        let usertype = UserDefaultsManager.shared.getUserType()
        
        if usertype == UserType.manager.rawValue {
            self.warehouseIdTxt.text = "User Id: \(productRecord?.userid ?? "")"
        } else {
            self.warehouseIdTxt.text = "Warehouse Id: \(productRecord?.warehouseID ?? "")"
        }

        self.priceTxt.text = "Price per Product: \(productRecord?.price ?? "")"
    }
    
    func calculatePricePerProduct(){
        let quantityString = productRecord?.quantity ?? ""
        let pricePerProductString = productRecord?.price ?? ""

        let cleanedPriceString = pricePerProductString.replacingOccurrences(of: "$", with: "")

        if let quantity = Int(quantityString), let pricePerProduct = Double(cleanedPriceString) {
            let totalPrice = Double(quantity) * pricePerProduct
            self.totalPrice = String(format: "%.2f", totalPrice)
            
            print("Total price: $\(self.totalPrice)")
            
            self.payBtn.setTitle("Pay $\(self.totalPrice)", for: .normal)
        } else {
            print("Invalid input")
        }
    }
    
    @IBAction func onMakePayment(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentScreen") as! PaymentScreen
        vc.payamount = self.totalPrice
        vc.requestId = self.productRecord?.requestId ?? ""
        vc.managerId = self.productRecord?.managerid ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
