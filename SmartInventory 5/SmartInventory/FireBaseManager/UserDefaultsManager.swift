 
import Foundation

class UserDefaultsManager  {
    
    static  let shared =  UserDefaultsManager()
    
    func clearUserDefaults() {
        
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()

            dictionary.keys.forEach
            {
                key in   defaults.removeObject(forKey: key)
            }
    }
        
    
    func isLoggedIn() -> Bool{
        
        let email = getEmail()
        
        if(email.isEmpty) {
            return false
        }else {
           return true
        }
      
    }
     
    func getEmail()-> String {
        
        let email = UserDefaults.standard.string(forKey: "email") ?? ""
        
        print(email)
       return email
    }
   
    func getUserType()-> String {
       return UserDefaults.standard.string(forKey: "userType") ?? ""
    }
    
    func getUserId()-> String {
       return UserDefaults.standard.string(forKey: "userid") ?? ""
    }
    
    func getDocumentId()-> String {
       return UserDefaults.standard.string(forKey: "documentId") ?? ""
    }
    
    func getUserWarehouseId()-> String {
       return UserDefaults.standard.string(forKey: "userWarehouseId") ?? ""
    }
    
    func saveData(email:String, userType: String, userWarehouseId: String,userId:String) {
    
        
        UserDefaults.standard.setValue(email, forKey: "email")
        UserDefaults.standard.setValue(userType, forKey: "userType")
        UserDefaults.standard.setValue(userWarehouseId, forKey: "userWarehouseId")
        UserDefaults.standard.setValue(userId, forKey: "userid")
    }
  
    func clearData(){
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "userType")
        UserDefaults.standard.removeObject(forKey: "documentId")
    }
}
