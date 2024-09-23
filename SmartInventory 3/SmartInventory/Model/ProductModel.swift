//
//  RequestModel.swift
//  SmartInventory
//
//  Created by Macbook-Pro on 11/09/24.
//

import Foundation
//struct RequestModel {
//    let productname: String
//    let warehouseID: String
//    let upcNumber: String
//    let quantity: String
//    let category: String
//    let managerId: String
//    let availableQuantity: String
//
//    init(productname: String, warehouseID: String, upcNumber: String, quantity: String, category: String, managerId: String, availableQuantity: String) {
//        self.productname = productname
//        self.warehouseID = warehouseID
//        self.upcNumber = upcNumber
//        self.quantity = quantity
//        self.category = category
//        self.managerId = managerId
//        self.availableQuantity = availableQuantity
//    }
//
//    // Convert the Product model into a dictionary for Firestore
//    func toDictionary() -> [String: Any] {
//        return [
//            "productname": productname,
//            "warehouseID": warehouseID,
//            "UPC number": upcNumber,
//            "quantity": quantity,
//            "category": category,
//            "managerId": managerId,
//            "availableQuantity": availableQuantity
//        ]
//    }
//    
//    // Optional: Initialize from Firestore data
//    init?(dictionary: [String: Any]) {
//        guard let productname = dictionary["productname"] as? String,
//              let warehouseID = dictionary["warehouseID"] as? String,
//              let upcNumber = dictionary["UPC number"] as? String,
//              let quantity = dictionary["quantity"] as? String,
//              let category = dictionary["category"] as? String,
//              let availableQuantity = dictionary["availableQuantity"] as? String,
//              let managerId = dictionary["managerId"] as? String else {
//            return nil
//        }
//        
//        self.productname = productname
//        self.warehouseID = warehouseID
//        self.upcNumber = upcNumber
//        self.quantity = quantity
//        self.category = category
//        self.managerId = managerId
//        self.availableQuantity = availableQuantity
//    }
//}
