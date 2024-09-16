//
//  ProductModel.swift
//  SmartInventory
//
//  Created by Macbook-Pro on 11/09/24.
//

import Foundation
struct ProductModel {
    let productname: String
    let warehouseID: String
    let upcNumber: String
    let quantity: String
    let category: String
    
    // This initializer allows easy creation of a Product from a dictionary (e.g., from Firestore)
    init(productname: String, warehouseID: String, upcNumber: String, quantity: String, category: String) {
        self.productname = productname
        self.warehouseID = warehouseID
        self.upcNumber = upcNumber
        self.quantity = quantity
        self.category = category
    }

    // Convert the Product model into a dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "productname": productname,
            "warehouseID": warehouseID,
            "UPC number": upcNumber,
            "quantity": quantity,
            "category": category
        ]
    }
    
    // Optional: Initialize from Firestore data
    init?(dictionary: [String: Any]) {
        guard let productname = dictionary["productname"] as? String,
              let warehouseID = dictionary["warehouseID"] as? String,
              let upcNumber = dictionary["UPC number"] as? String,
              let quantity = dictionary["quantity"] as? String,
              let category = dictionary["category"] as? String else {
            return nil
        }
        
        self.productname = productname
        self.warehouseID = warehouseID
        self.upcNumber = upcNumber
        self.quantity = quantity
        self.category = category
    }
}
