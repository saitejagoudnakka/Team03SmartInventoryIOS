
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Firebase


class FireStoreManager {
    
    public static let shared = FireStoreManager()
    var hospital = [String]()
    
    var db: Firestore!
    var dbRef : CollectionReference!

    init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        dbRef = db.collection("Users")

    }
    
    func signUp(email:String,password:String,userType:String) {
        
        self.checkAlreadyExistAndSignup(email:email,password:password,userType:userType)
    }
    
    func login(email:String,password:String,completion: @escaping (Bool)->()) {
        let  query = db.collection("Users").whereField("email", isEqualTo: email)
        
        query.getDocuments { (querySnapshot, err) in
            
            print(querySnapshot?.count)
            
            if(querySnapshot?.count == 0) {
                showAlerOnTop(message: "Email id not found!!")
            }else {
                
                for document in querySnapshot!.documents {
                    print("doclogin = \(document.documentID)")
                    UserDefaults.standard.setValue("\(document.documentID)", forKey: "documentId")
                    
                    if let pwd = document.data()["password"] as? String{
                        
                        if(pwd == password) {
                            
                
                            let email = document.data()["email"] as? String ?? ""
                            let userType = document.data()["userType"] as? String ?? ""
                            
                            UserDefaultsManager.shared.saveData(email: email, userType: userType)
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
                    UserDefaultsManager.shared
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
    
    func checkAlreadyExistAndSignup(email:String,password:String,userType:String) {
        
        getQueryFromFirestore(field: "email", compareValue: email) { querySnapshot in
            
            print(querySnapshot.count)
            
            if(querySnapshot.count > 0) {
                showAlerOnTop(message: "This Email is Already Registerd!!")
            }else {
                
                // Signup
                
                let data = ["email":email,"password":password,"userType":userType] as [String : Any]
                
                self.addDataToFireStore(data: data) { _ in
                    
                    
                    showOkAlertAnyWhereWithCallBack(message: "Registration Success!!") {
                        
                        DispatchQueue.main.async {
                            SceneDelegate.shared?.loginCheckOrRestart()
                        }
                        
                    }
                    
                }
                
            }
        }
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
    
    func addProductDetail(documentID: String, email: String, data: ProductModel,completionHandler: @escaping (Bool)->()) 
    {
//        let data = ["patientId": data.patientId ?? "",
//                    "pFirstname": data.pFirstname ?? "",
//                    "pLastname": data.pLastname ?? "",
//                    "pMiddlename": data.pMiddlename ?? "",
//                    "doctorName": data.doctorName ?? "",
//                    "hospitalName": data.hospitalName ?? "",
//                    "medicalEmergency": data.medicalEmergency ?? "",
//                    "date": data.date ?? "",
//                    "time": data.time ?? "",
//                    "medicalHistory": data.medicalHistory ?? "",
//                    "status": data.status ?? "",
//                    "doctorEmail": data.doctorEmail ?? "",
//                    "patientEmail": data.patientEmail ?? "",
//                    "bookingDate": data.bookingDate ?? 0.0,
//                    "documentId": data.documentId ?? ""] as [String : Any]
//        let query = self.dbRef.document(UserDefaultsManager.shared.getDocumentId()).collection("Appoinments")
//        query.document(appointDocumentID).updateData(data) { success in
//                    return completionHandler(true)
//        }

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
}
