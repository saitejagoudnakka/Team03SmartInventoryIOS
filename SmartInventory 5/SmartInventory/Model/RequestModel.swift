
import Foundation
import FirebaseCore
import FirebaseFirestore

struct RequestModel {
    let productname: String?
    let warehouseID: String?
    let upcNumber: String?
    let quantity: String?
    let shippingFile: String?
    let userid: String?
    var date: Date?
    var managerid: String?
    var requestId: String?
    let category: String?
    let availableQuantity: String?
    let managerEmail: String?
    let userEmail: String?
    let price: String?
    let paymentStatus: String?
    let trackingNumber: String?
    var status_accepted_rejected: String?
    var status_accepted_rejected_time: Date?
    var packageStatus: String?
    var added_time: Int
    var approved_time: Int?
    var checkInDate: Date?
    var checkOutDate: Date?

    // Initializer
    init(productname: String, warehouseID: String, upcNumber: String, quantity: String, shippingFile: String, userid: String, managerid: String, requestId: String, category: String, availableQuantity: String, managerEmail: String, userEmail: String, price: String, paymentStatus: String, trackingNumber: String, date: Date = Date(), status_accepted_rejected_time: Date = Date(), status_accepted_rejected: String, packageStatus: String, added_time: Int, approved_time: Int, checkInDate: Date? = nil, checkOutDate: Date? = nil) {
        self.productname = productname
        self.warehouseID = warehouseID
        self.upcNumber = upcNumber
        self.quantity = quantity
        self.shippingFile = shippingFile
        self.userid = userid
        self.managerid = managerid
        self.requestId = requestId
        self.category = category
        self.availableQuantity = availableQuantity
        self.managerEmail = managerEmail
        self.userEmail = userEmail
        self.price = price
        self.paymentStatus = paymentStatus
        self.date = date
        self.trackingNumber = trackingNumber
        self.status_accepted_rejected_time = status_accepted_rejected_time
        self.status_accepted_rejected = status_accepted_rejected
        self.packageStatus = packageStatus
        self.added_time = added_time
        self.approved_time = approved_time
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
    }

    // Convert to dictionary
    func toDictionary() -> [String: Any] {
        return [
            "productname": productname ?? "",
            "warehouseID": warehouseID ?? "",
            "upcNumber": upcNumber ?? "",
            "quantity": quantity ?? "",
            "shippingFile": shippingFile ?? "",
            "userid": userid ?? "",
            "managerid": managerid ?? "",
            "requestId": requestId ?? "",
            "category": category ?? "",
            "availableQuantity": availableQuantity ?? "",
            "managerEmail": managerEmail ?? "",
            "userEmail": userEmail ?? "",
            "price": price ?? "",
            "trackingNumber": trackingNumber ?? "",
            "paymentStatus": paymentStatus ?? "",
            "added_time": added_time,
            "approved_time": approved_time ?? 0,
            "packageStatus": packageStatus ?? "",
            "status_accepted_rejected": status_accepted_rejected ?? "",
            "status_accepted_rejected_time": Timestamp(date: status_accepted_rejected_time ?? Date()),
            "date": Timestamp(date: date!),
            "checkInDate": checkInDate != nil ? Timestamp(date: checkInDate!) : NSNull(),
            "checkOutDate": checkOutDate != nil ? Timestamp(date: checkOutDate!) : NSNull()
        ]
    }

    // Initialize from dictionary
    init?(dictionary: [String: Any]) {
        guard let productname = dictionary["productname"] as? String,
              let warehouseID = dictionary["warehouseID"] as? String,
              let upcNumber = dictionary["upcNumber"] as? String,
              let quantity = dictionary["quantity"] as? String,
              let shippingFile = dictionary["shippingFile"] as? String,
              let userid = dictionary["userid"] as? String,
              let managerid = dictionary["managerid"] as? String,
              let requestId = dictionary["requestId"] as? String,
              let category = dictionary["category"] as? String,
              let availableQuantity = dictionary["availableQuantity"] as? String,
              let managerEmail = dictionary["managerEmail"] as? String,
              let userEmail = dictionary["userEmail"] as? String,
              let price = dictionary["price"] as? String,
              let trackingNumber = dictionary["trackingNumber"] as? String,
              let paymentStatus = dictionary["paymentStatus"] as? String,
              let packageStatus = dictionary["packageStatus"] as? String,
              let added_time = dictionary["added_time"] as? Int,
              let approved_time = dictionary["approved_time"] as? Int,
              let status_accepted_rejected = dictionary["status_accepted_rejected"] as? String,
              let status_accepted_rejected_time = dictionary["status_accepted_rejected_time"] as? Timestamp,
              let timestamp = dictionary["date"] as? Timestamp else {
            return nil
        }

        self.productname = productname
        self.warehouseID = warehouseID
        self.upcNumber = upcNumber
        self.quantity = quantity
        self.shippingFile = shippingFile
        self.userid = userid
        self.managerid = managerid
        self.requestId = requestId
        self.category = category
        self.availableQuantity = availableQuantity
        self.managerEmail = managerEmail
        self.userEmail = userEmail
        self.price = price
        self.paymentStatus = paymentStatus
        self.packageStatus = packageStatus
        self.added_time = added_time
        self.approved_time = approved_time
        self.trackingNumber = trackingNumber
        self.date = timestamp.dateValue()
        self.status_accepted_rejected = status_accepted_rejected
        self.status_accepted_rejected_time = status_accepted_rejected_time.dateValue()
        self.checkInDate = (dictionary["checkInDate"] as? Timestamp)?.dateValue()
        self.checkOutDate = (dictionary["checkOutDate"] as? Timestamp)?.dateValue()
    }
}


