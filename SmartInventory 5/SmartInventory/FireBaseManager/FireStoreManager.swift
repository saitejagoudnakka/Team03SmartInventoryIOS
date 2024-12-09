
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Firebase
import SwiftSMTP


class FireStoreManager {
    
    public static let shared = FireStoreManager()
    var hospital = [String]()
    
    var db: Firestore!
    var dbRef : CollectionReference!
    var dbRefWarehouse : CollectionReference!
    
    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        dbRef = db.collection("Users")
        dbRefWarehouse = db.collection("Warehouses")
    }
    
    func signUp(email:String,password:String,userType:String,warehouseid: String) {
        self.checkAlreadyExistAndSignup(email:email,password:password,userType:userType,warehouseid:warehouseid)
    }
    
    func login(email:String,password:String,completion: @escaping (Bool)->()) {
        let  query = db.collection("Users").whereField("email", isEqualTo: email)
        
        query.getDocuments { (querySnapshot, err) in
            
            print(querySnapshot?.count)
            
            if(querySnapshot?.count == 0) {
                showAlerOnTop(message: "Email id not found!!")
            }else {
                
                for document in querySnapshot!.documents {
                   // print("doclogin = \(document.documentID)")
                    //UserDefaults.standard.setValue("\(document.documentID)", forKey: "documentId")
                    
                    if let pwd = document.data()["password"] as? String{
                        
                        if(pwd == password) {
                            
                            
                            
                            let email = document.data()["email"] as? String ?? ""
                            let userType = document.data()["userType"] as? String ?? ""
                            let userWarehouseId = document.data()["warehouseid"] as? String ?? ""
                            let userid = document.data()["userid"] as? String ?? document.data()["managerid"] as? String ?? ""
                            UserDefaults.standard.setValue(userid, forKey: "documentId")
                            
                            print("data ==== ",userid , userWarehouseId, UserDefaultsManager.shared.getDocumentId())
                            UserDefaultsManager.shared.saveData(email: email, userType: userType, userWarehouseId: userWarehouseId, userId: userid)
                            completion(true)
                            
                        }else {
                            showAlerOnTop(message: "Password doesn't match")
                        }
                        
                        
                    }else {
                        showAlerOnTop(message: "Something went wrong!!")
                    }
                }
            }
        }
    }
    
    func getPassword(email:String,password:String,completion: @escaping (String)->()) {
        let  query = db.collection("Users").whereField("email", isEqualTo: email)
        
        query.getDocuments { (querySnapshot, err) in
            
            if(querySnapshot?.count == 0) {
                showAlerOnTop(message: "Email id not found!!")
            }else {
                
                for document in querySnapshot!.documents {
                    print("doclogin = \(document.documentID)")
                    UserDefaults.standard.setValue("\(document.documentID)", forKey: "documentId")
                    if let pwd = document.data()["password"] as? String{
                        completion(pwd)
                    }else {
                        showAlerOnTop(message: "Something went wrong!!")
                    }
                }
            }
        }
    }
    

    /// Function to send email
    func sendEmail(to email: String, password: String) {
        // SMTP Server Configuration
        let smtp = SMTP(
            hostname: "smtp.gmail.com",   // Gmail SMTP server
            email: "smartinventorygdp@gmail.com", // Your Gmail address
            password: "fhwwnbhvqwiocejv" // Your Gmail app password
        )

        // Email Content
        let from = Mail.User(name: "Smart Inventory", email: "your-email@gmail.com")
        let to = Mail.User(name: "User", email: email)
        let mail = Mail(
            from: from,
            to: [to],
            subject: "Password Recovery - Smart Inventory",
            text: """
            Hello,

            You requested to recover your password for your Smart Inventory account.

            Your password is: \(password)

            Please keep your password secure and do not share it with anyone.

            Regards,
            Smart Inventory
            """
        )

        // Send the Email
        smtp.send(mail) { error in
            if let error = error {
                print("Failed to send email: \(error)")
                DispatchQueue.main.async {
                     showAlerOnTop(message: "Failed to send password recovery email. Please try again later.")
                }
            } else {
                print("Email sent successfully!")
                DispatchQueue.main.async {
                     showAlerOnTop(message: "Password recovery email has been sent successfully!")
                }
            }
        }
    }


    func checkAlreadyExistAndSignup(email:String,password:String,userType:String,warehouseid: String) {
        
        getQueryFromFirestore(field: "email", compareValue: email) { querySnapshot in
            
            print(querySnapshot.count)
            
            if(querySnapshot.count > 0) {
                showAlerOnTop(message: "This Email is Already Registerd!!")
            } else {
                
                // Signup
                var data: [String: Any] = [
                    "email": email,
                    "password": password,
                    "userType": userType,
                    (userType == "Manager" ? "managerid" : "userid"): self.random(digits: 12)
                ]

                if userType == "Manager" {
                    data["warehouseid"] = warehouseid
                }
                
                self.addDataToFireStore(data: data) { _ in
                    
                    showOkAlertAnyWhereWithCallBack(message: "Registration Success!!") {
                        
                        if userType == "Manager" {
                            self.addRandomNumberDocumentToWarehouses(warehouseid: warehouseid)
                        }
                        
                        DispatchQueue.main.async {
                            SceneDelegate.shared?.loginCheckOrRestart()
                        }
                    }
                }
            }
        }
    }
    
    func addRandomNumberDocumentToWarehouses(warehouseid: String) {
        dbRefWarehouse.document(warehouseid).setData([
            "WarehouseId": warehouseid // or leave empty if you just want the document ID
        ]) { error in
            if let error = error {
                print("Error adding document with random ID to Warehouses collection: \(error)")
            } else {
                print("Document added successfully with random ID: \(warehouseid)")
            }
        }
    }
    
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
    func getQueryFromFirestore(field:String,compareValue:String,completionHandler:@escaping (QuerySnapshot) -> Void){
        
        dbRef.whereField(field, isEqualTo: compareValue).getDocuments { querySnapshot, err in
            
            if let err = err {
                
                showAlerOnTop(message: "Error getting documents: \(err)")
                return
            }else {
                
                if let querySnapshot = querySnapshot {
                    return completionHandler(querySnapshot)
                }else {
                    showAlerOnTop(message: "Something went wrong!!")
                }
                
            }
        }
        
    }
    
    func addDataToFireStore(data: [String: Any], completionHandler: @escaping (Any) -> Void) {
        let dbr = db.collection("Users")
        dbr.addDocument(data: data) { err in
            if let err = err {
                showAlerOnTop(message: "Error adding document: \(err)")
            } else {
                completionHandler("success")
            }
        }
    }
    
    func addProductDetail(wareHouseId: String, product: RequestModel, completionHandler: @escaping (Bool) -> ()) {
        
        let warehouseRef = dbRefWarehouse.document(wareHouseId)
        let productData = product.toDictionary()
        
        // Fetch the warehouse document
        warehouseRef.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completionHandler(false)
                return
            }
            
            if let document = document, document.exists {
                // If document exists, update the product array
                warehouseRef.updateData([
                    "products": FieldValue.arrayUnion([productData])
                ]) { error in
                    if let error = error {
                        print("Error adding product to array: \(error.localizedDescription)")
                        completionHandler(false)
                    } else {
                        completionHandler(true)
                    }
                }
            } else {
                // If document doesn't exist, create the document with the product array
                warehouseRef.setData([
                    "products": [productData]
                ]) { error in
                    if let error = error {
                        print("Error creating document: \(error.localizedDescription)")
                        completionHandler(false)
                    } else {
                        completionHandler(true)
                    }
                }
            }
        }
    }
    
    
    func fetchAllProductData(completionHandler: @escaping ([RequestModel]?, Error?) -> ()) {
        let query = self.dbRef.document(UserDefaultsManager.shared.getDocumentId()).collection("Products")
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completionHandler(nil, error)
            } else {
                var products: [RequestModel] = []
                
                for document in snapshot?.documents ?? [] {
                    if let product = RequestModel(dictionary: document.data()) {
                        products.append(product)
                    }
                }
                completionHandler(products, nil)
            }
        }
    }
    
    func getWarehouseDocumentIDs(completion: @escaping ([String]?) -> Void) {
        self.dbRefWarehouse.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                completion(nil)
            } else {
                var documentIDs: [String] = []
                
                for document in querySnapshot!.documents {
                    documentIDs.append(document.documentID)
                }
                completion(documentIDs)
            }
        }
    }
    
    func changePassword(documentid:String, userData: [String:String] ,completion: @escaping (Bool)->()) {
        let  query = db.collection("Users").document(documentid)
        
        query.updateData(userData) { error in
            if let error = error {
                print("Error updating Firestore data: \(error.localizedDescription)")
            } else {
                print("Password updated successfully")
                completion(true)
            }
        }
    }
    
    func updateUserPasswordByEmail(email: String, newPassword: String,completion: @escaping (Bool)->()) {
        self.dbRef.whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    for document in documents {
                        let documentRef = document.reference
                        
                        documentRef.updateData([
                            "password": newPassword
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                completion(true)
                                print("Password updated successfully for user: \(email)")
                            }
                        }
                    }
                } else {
                    completion(false)
                    print("No user found with the email \(email)")
                }
            }
        }
    }
    
    func addNewReport(email: String, fileName: String, addReportName: String, reportUrlPath: String,completion: @escaping (Bool)->()) {
        self.dbRef.whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("err")
                // Some error occured
            } else if querySnapshot!.documents.count != 1 {
                showAlerOnTop(message: "Error in addition")
            } else {
                let data = ["fileName":fileName,"addReportName":addReportName,"reportUrlPath":reportUrlPath] as [String : Any]
                
                let document = querySnapshot!.documents.first
                document?.reference.updateData([
                    "ReportDetail": FieldValue.arrayUnion([data])
                ])
                completion(true)
            }
        }
        
    }
    
//    func addProductRequest(warehouseID: String, UPC: String, request: RequestModel, completionHandler: @escaping (Bool) -> ()) {
//        
//        let ref = dbRef.document(UserDefaultsManager.shared.getDocumentId())
//        let product = request.toDictionary()
//        
//        ref.collection("ProductRequestToManager")
//            .whereField("productname", isEqualTo: request.productname ?? "")
//            .whereField("upcNumber", isEqualTo: request.upcNumber ?? "")
//            .whereField("managerid", isEqualTo: request.managerid ?? "")
//            .getDocuments { (querySnapshot, error) in
//                if let error = error {
//                    print("Error fetching RequestBid documents: \(error.localizedDescription)")
//                    completionHandler(false)
//                    return
//                }
//                
//                if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
//                    print("Product already exists in Request. Not Request again.")
//                    completionHandler(false)
//                    return
//                }
//                
//                let warehouseRef = self.dbRefWarehouse.document(warehouseID)
//                
//                warehouseRef.getDocument { (documentSnapshot, error) in
//                    if let error = error {
//                        print("Error fetching document: \(error.localizedDescription)")
//                        completionHandler(false)
//                        return
//                    }
//                    
//                    guard let document = documentSnapshot, document.exists, let data = document.data() else {
//                        print("Warehouse document does not exist")
//                        completionHandler(false)
//                        return
//                    }
//                    
//                    if let productsArray = data["products"] as? [[String: Any]] {
//                        if let product = productsArray.first(where: {
//                            $0["warehouseID"] as? String == warehouseID && $0["upcNumber"] as? String == UPC
//                        }) {
//                            if let managerID = product["managerid"] as? String {
//                                
//                                let requestData = request.toDictionary()
//                                let userRef = self.dbRef.document(managerID).collection("ProductRequest").document(request.requestId ?? "")
//                                
//                                userRef.setData(requestData) { error in
//                                    if let error = error {
//                                        print("Error adding request to user's requests: \(error.localizedDescription)")
//                                        completionHandler(false)
//                                    } else {
//                                        
//                                        let requestData = request.toDictionary()
//                                        let userRef = self.dbRef.document(UserDefaultsManager.shared.getDocumentId()).collection("ProductRequestToManager").document(request.requestId ?? "")
//                                        
//                                        userRef.setData(requestData) { error in
//                                            if let error = error {
//                                                print("Error adding request to ProductRequestToManager: \(error.localizedDescription)")
//                                                completionHandler(false)
//                                            } else {
//                                                print("Request successfully added to ProductRequestToManager collection")
//                                                completionHandler(true)
//                                            }
//                                            
//                                        }
//                                    }
//                                }
//                            } else {
//                                print("Manager ID not found in the product")
//                                completionHandler(false)
//                            }
//                        } else {
//                            print("Product with matching UPC not found")
//                            completionHandler(false)
//                        }
//                    } else {
//                        print("No products found in the warehouse")
//                        completionHandler(false)
//                    }
//                }
//            }
//    }
//    
    
    func addProductRequest(warehouseID: String, UPC: String, request: RequestModel, completionHandler: @escaping (Bool) -> ()) {
        let ref = dbRef.document(UserDefaultsManager.shared.getDocumentId())
        let productData = request.toDictionary()
        
        let warehouseRef = self.dbRefWarehouse.document(warehouseID)
        
        warehouseRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching warehouse document: \(error.localizedDescription)")
                completionHandler(false)
                return
            }
            
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("Warehouse document does not exist")
                completionHandler(false)
                return
            }
            
            if let productsArray = data["products"] as? [[String: Any]] {
                if let product = productsArray.first(where: {
                    $0["warehouseID"] as? String == warehouseID && $0["upcNumber"] as? String == UPC
                }) {
                    if let managerID = product["managerid"] as? String {
                        // Add request to the manager's "ProductRequest" collection
                        let managerRequestRef = self.dbRef.document(managerID).collection("ProductRequest").document(request.requestId ?? "")
                        
                        managerRequestRef.setData(productData) { error in
                            if let error = error {
                                print("Error adding request to manager's ProductRequest: \(error.localizedDescription)")
                                completionHandler(false)
                            } else {
                                // Add request to the user's "ProductRequestToManager" collection
                                let userRequestRef = self.dbRef.document(UserDefaultsManager.shared.getDocumentId()).collection("ProductRequestToManager").document(request.requestId ?? "")
                                
                                userRequestRef.setData(productData) { error in
                                    if let error = error {
                                        print("Error adding request to ProductRequestToManager: \(error.localizedDescription)")
                                        completionHandler(false)
                                    } else {
                                        print("Request successfully added to both collections")
                                        completionHandler(true)
                                    }
                                }
                            }
                        }
                    } else {
                        print("Manager ID not found in the product")
                        completionHandler(false)
                    }
                } else {
                    print("Product with matching UPC not found in the warehouse")
                    completionHandler(false)
                }
            } else {
                print("No products found in the warehouse")
                completionHandler(false)
            }
        }
    }
    
    
    func getProductRequests(forUserId userId: String, completionHandler: @escaping ([RequestModel]?, Error?) -> ()){
        let userRef = self.dbRef.document(userId).collection("ProductRequest")

        userRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching bid requests: \(error.localizedDescription)")
                completionHandler(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No product requests found")
                completionHandler([], nil)
                return
            }

            let productRequests = documents.compactMap { document -> RequestModel? in
                let data = document.data()
                return RequestModel(dictionary: data)
            }

            completionHandler(productRequests, nil)
        }
    }
    
    func getAcceptedProductRequests(forUserId userId: String, completionHandler: @escaping ([RequestModel]?, Error?) -> ()){
        let userRef = self.dbRef.document(userId).collection("AcceptedProduct")

        userRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching bid requests: \(error.localizedDescription)")
                completionHandler(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No product requests found")
                completionHandler([], nil)
                return
            }

            let productRequests = documents.compactMap { document -> RequestModel? in
                let data = document.data()
                return RequestModel(dictionary: data)
            }

            completionHandler(productRequests, nil)
        }
    }
    
    func getRejectedProductRequests(forUserId userId: String, completionHandler: @escaping ([RequestModel]?, Error?) -> ()){
        let userRef = self.dbRef.document(userId).collection("RejectedProduct")

        userRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching bid requests: \(error.localizedDescription)")
                completionHandler(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No product requests found")
                completionHandler([], nil)
                return
            }

            let productRequests = documents.compactMap { document -> RequestModel? in
                let data = document.data()
                return RequestModel(dictionary: data)
            }

            completionHandler(productRequests, nil)
        }
    }

    func updatePackageStatus(forUserId userId: String, requestId: String, status: String, completionHandler: @escaping (Error?) -> ()) {
        let userRef = self.dbRef.document(userId).collection("AcceptedProduct").document(requestId)
        userRef.updateData(["packageStatus": status]) { error in
            if let error = error {
                print("Error updating package status: \(error.localizedDescription)")
                completionHandler(error)
            } else {
                print("Package status successfully updated to \(status)")
                completionHandler(nil)
            }
        }
    }
    
    func acceptProductRequest(documentid: String, warehouseID: String, UPC: String, userid: String, productName: String, request: RequestModel, completionHandler: @escaping (Bool) -> ()) {
        let ref = self.dbRef.document(UserDefaultsManager.shared.getDocumentId()).collection("ProductRequest")
        
        ref.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completionHandler(false)
                return
            }
            
            guard let querySnapshot = querySnapshot, !querySnapshot.isEmpty else {
                print("No documents found in ProductRequest collection")
                completionHandler(false)
                return
            }
            
                let userRef = self.dbRef.document(documentid)
                
            let rejectProductRef = userRef.collection("AcceptedProduct").document(request.requestId ?? "")
                
            rejectProductRef.setData(request.toDictionary()) { error in
                    if let error = error {
                        print("Error adding product to RejectProduct collection: \(error.localizedDescription)")
                        completionHandler(false)
                        return
                    } else {
                        print("Product successfully added to RejectProduct collection")
                        
                        let userRequestRef = self.dbRef.document(userid).collection("AcceptedProductRequest").document(request.requestId ?? "")
                        
                        userRequestRef.setData(request.toDictionary()) { error in
                            if let error = error {
                                print("Error adding request to user's RejectProductRequest collection: \(error.localizedDescription)")
                                completionHandler(false)
                                return
                            } else {
                                // Step 3: Delete the document from "ProductRequest" collection
                                ref.document(request.requestId ?? "").delete { error in
                                    if let error = error {
                                        print("Error deleting product request from ProductRequest collection: \(error.localizedDescription)")
                                        completionHandler(false)
                                    } else {
                                        let userref = self.dbRef.document(request.userid ?? "").collection("ProductRequestToManager")
                                        
                                        userref.document(request.requestId ?? "").delete { error in
                                            if let error = error {
                                                print("Error deleting product request from ProductRequest collection: \(error.localizedDescription)")
                                                completionHandler(false)
                                            } else {
                                                
                                                print("Product request successfully deleted from ProductRequest collection")
                                               // completionHandler(true)
                                            }
                                        }
                                        
                                        print("Product request successfully deleted from ProductRequest collection")
                                        self.updateWarehouseProductQuantity(warehouseID: warehouseID, product: request) { success in
                                                       if success {
                                                           print("Product quantity successfully updated in warehouse")
                                                           completionHandler(true)
                                                       } else {
                                                           print("Failed to update product quantity in warehouse")
                                                           completionHandler(false)
                                                       }
                                                   }                                    }
                                }
                            }
                        }
                    }
                }
            
        }
    }


    func rejectProductRequest(documentid: String, warehouseID: String, UPC: String, userid: String, productName: String, request: RequestModel, completionHandler: @escaping (Bool) -> ()) {
        let ref = self.dbRef.document(UserDefaultsManager.shared.getDocumentId()).collection("ProductRequest")
        
        ref.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                completionHandler(false)
                return
            }
            
            guard let querySnapshot = querySnapshot, !querySnapshot.isEmpty else {
                print("No documents found in ProductRequest collection")
                completionHandler(false)
                return
            }
            
                let userRef = self.dbRef.document(documentid)
                
            let rejectProductRef = userRef.collection("RejectedProduct").document(request.requestId ?? "")
                
            rejectProductRef.setData(request.toDictionary()) { error in
                    if let error = error {
                        print("Error adding product to RejectProduct collection: \(error.localizedDescription)")
                        completionHandler(false)
                        return
                    } else {
                        print("Product successfully added to RejectProduct collection")
                        
                        let userRequestRef = self.dbRef.document(userid).collection("RejectedProductRequest").document(request.requestId ?? "")
                        
                        userRequestRef.setData(request.toDictionary()) { error in
                            if let error = error {
                                print("Error adding request to user's RejectProductRequest collection: \(error.localizedDescription)")
                                completionHandler(false)
                                return
                            } else {
                                ref.document(request.requestId ?? "").delete { error in
                                    if let error = error {
                                        print("Error deleting product request from ProductRequest collection: \(error.localizedDescription)")
                                        completionHandler(false)
                                    } else {
                                        let userref = self.dbRef.document(request.userid ?? "").collection("ProductRequestToManager")
                                        
                                        userref.document(request.requestId ?? "").delete { error in
                                            if let error = error {
                                                print("Error deleting product request from ProductRequest collection: \(error.localizedDescription)")
                                                completionHandler(false)
                                            } else {
                                                
                                                print("Product request successfully deleted from ProductRequest collection")
                                                //completionHandler(true)
                                            }
                                        }
                                        
                                        print("Product request successfully deleted from ProductRequest collection")
                                        completionHandler(true)
                                    }
                                }
                            }
                        }
                    }
                }
            
        }
    }

    func updateWarehouseProductQuantity(warehouseID: String, product: RequestModel, completionHandler: @escaping (Bool) -> ()) {
        let warehouseRef = dbRefWarehouse.document(warehouseID)
        
        warehouseRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching warehouse document: \(error.localizedDescription)")
                completionHandler(false)
                return
            }
            
            guard let document = document, document.exists, var warehouseData = document.data(), var products = warehouseData["products"] as? [[String: Any]] else {
                print("Warehouse document does not exist or has no products")
                completionHandler(false)
                return
            }
                
            if let index = products.firstIndex(where: { ($0["managerid"] as? String) == product.managerid && ($0["upcNumber"] as? String) == product.upcNumber && ($0["productname"] as? String) == product.productname}) {
                
                var updatedProduct = products[index]
                
                if let currentQuantityString = updatedProduct["quantity"] as? String, let currentQuantity = Int(currentQuantityString) {

                    let productQuantityString = product.quantity ?? "0"
                    let productQuantity = Int(productQuantityString) ?? 0

                    let newQuantity = currentQuantity - productQuantity
                    print("currentQuantity: \(currentQuantity), productQuantity: \(productQuantity), newQuantity: \(newQuantity)")
                    
                    updatedProduct["quantity"] = "\(newQuantity)"
                    
                    products[index] = updatedProduct
                    
                    warehouseRef.updateData([
                        "products": products
                    ]) { error in
                        if let error = error {
                            print("Error updating product quantity in warehouse: \(error.localizedDescription)")
                            completionHandler(false)
                        } else {
                            print("Product quantity updated successfully")
                            completionHandler(true)
                        }
                    }
                } else {
                    print("Invalid or missing current quantity")
                    completionHandler(false)
                }
            } else {
                print("Product not found in warehouse")
                completionHandler(false)
            }
        }
    }


    func getAllWarehouseProducts(completionHandler: @escaping ([RequestModel]?) -> ()) {
        let warehouseRef = dbRefWarehouse
        
        warehouseRef?.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching warehouse documents: \(error.localizedDescription)")
                completionHandler(nil)
                return
            }
            
            var allProducts: [RequestModel] = []
            let userid=UserDefaultsManager.shared.getUserId()
            
            querySnapshot?.documents.forEach { document in
                if let data = document.data()["products"] as? [[String: Any]] {
                    let products = data.compactMap { RequestModel(dictionary: $0) }
                    let filteredProducts = products.filter{$0.userid == userid }
                    allProducts.append(contentsOf: filteredProducts)
                }
            }
            
            completionHandler(allProducts)
        }
    }
    
    func getAllAcceptedProductRecord(forUserId userId: String, completionHandler: @escaping ([RequestModel]?, Error?) -> ()){
        let userRef = self.dbRef.document(userId).collection("AcceptedProduct")

        userRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching bid requests: \(error.localizedDescription)")
                completionHandler(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No product requests found")
                completionHandler([], nil)
                return
            }

            let productRequests = documents.compactMap { document -> RequestModel? in
                let data = document.data()
                return RequestModel(dictionary: data)
            }

            completionHandler(productRequests, nil)
        }
    }
    
    func getAllRequestProductRecord(forUserId userId: String, collectionStatus: String, completionHandler: @escaping ([RequestModel]?, Error?) -> ()){
        let userRef = self.dbRef.document(userId).collection(collectionStatus)

        userRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching bid requests: \(error.localizedDescription)")
                completionHandler(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No product requests found")
                completionHandler([], nil)
                return
            }

            let productRequests = documents.compactMap { document -> RequestModel? in
                let data = document.data()
                return RequestModel(dictionary: data)
            }

            completionHandler(productRequests, nil)
        }
    }

    func updatePaymentStatus(forUserId userId: String, requestId: String, newPaymentStatus: String, completionHandler: @escaping (Bool, Error?) -> ()) {
        let userRef = dbRef.document(userId).collection("AcceptedProductRequest").document(requestId)
        
        userRef.getDocument { documentSnapshot, error in
            if let error = error {
                print("Error fetching product request: \(error.localizedDescription)")
                completionHandler(false, error)
                return
            }
            
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                print("Document does not exist for requestId: \(requestId)")
                completionHandler(false, nil)
                return
            }
            
            userRef.updateData(["paymentStatus": newPaymentStatus]) { error in
                if let error = error {
                    print("Error updating payment status: \(error.localizedDescription)")
                    completionHandler(false, error)
                } else {
                    print("Payment status updated successfully for requestId: \(requestId)")
                    completionHandler(true, nil)
                }
            }
        }
    }

    func updatePaymentStatusInManagerPaymentList(forManagerId : String, requestId: String, newPaymentStatus: String, completionHandler: @escaping (Bool, Error?) -> ()) {
        let userRefM = dbRef.document(forManagerId).collection("AcceptedProduct").document(requestId)
        
        userRefM.getDocument { documentSnapshot, error in
            if let error = error {
                print("manager Error fetching product request: \(error.localizedDescription)")
                completionHandler(false, error)
                return
            }
            
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                print("manager Document does not exist for requestId: \(requestId)")
                completionHandler(false, nil)
                return
            }
            
            userRefM.updateData(["paymentStatus": newPaymentStatus]) { error in
                if let error = error {
                    print("manager Error updating payment status: \(error.localizedDescription)")
                    completionHandler(false, error)
                } else {
                    print("manager Payment status updated successfully for requestId: \(requestId)")
                    completionHandler(true, nil)
                }
            }
        }
    }
    
    func getAcceptedProductsWithSuccessPayment(forUserId userId: String, completionHandler: @escaping ([RequestModel]?, Error?) -> ()) {
        let userRef = dbRef.document(userId).collection("AcceptedProductRequest")
        
        userRef.whereField("paymentStatus", isEqualTo: "Success").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching accepted products: \(error.localizedDescription)")
                completionHandler(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No accepted products with payment status 'success' found")
                completionHandler([], nil)
                return
            }
            
            let acceptedProducts = documents.compactMap { document -> RequestModel? in
                let data = document.data()
                return RequestModel(dictionary: data)
            }
            
            completionHandler(acceptedProducts, nil)
        }
    }
    
    func getReceivedPaymentProductsForManager(forManagerId: String, completionHandler: @escaping ([RequestModel]?, Error?) -> ()) {
        let userRef = dbRef.document(forManagerId).collection("AcceptedProduct")
        
        userRef.whereField("paymentStatus", isEqualTo: "Success").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching accepted products: \(error.localizedDescription)")
                completionHandler(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No accepted products with payment status 'success' found")
                completionHandler([], nil)
                return
            }
            
            let acceptedProducts = documents.compactMap { document -> RequestModel? in
                let data = document.data()
                return RequestModel(dictionary: data)
            }
            
            completionHandler(acceptedProducts, nil)
        }
    }

}
