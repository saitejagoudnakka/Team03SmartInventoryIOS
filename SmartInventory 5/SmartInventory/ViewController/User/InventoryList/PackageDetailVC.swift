//
//  PackageDetailVC.swift
//  SmartInventory
//
//  Created by Deepika Kunwar on 19/11/24.
//

import UIKit

class PackageDetailVC: BaseVC {
    @IBOutlet weak var checkinTxt: UITextField!
    @IBOutlet weak var checkoutTxt: UITextField!
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var upcTxt: UITextField!
    @IBOutlet weak var quantityTxt: UITextField!
    @IBOutlet weak var packageidTxt: UITextField!

    
    var productData: RequestModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showProductData()
    }
    
    
    func showProductData(){
        self.productNameTxt.text = productData?.productname
        self.packageidTxt.text = productData?.trackingNumber
        self.upcTxt.text = productData?.upcNumber
        self.quantityTxt.text = productData?.quantity
        
        let added_time = PackageListVC.formatDateTime(date: productData?.checkInDate)
        self.checkinTxt.text = added_time

        let approved_time = PackageListVC.formatDateTime(date: productData?.checkOutDate)
        
        self.checkoutTxt.text = approved_time

        
    }
    
}
