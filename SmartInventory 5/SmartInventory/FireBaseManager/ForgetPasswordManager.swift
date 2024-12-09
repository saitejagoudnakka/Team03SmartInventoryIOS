 
import UIKit

class ForgetPasswordManager {
    
  
    static func sendEmail(emailTo:String, body:String, completion: @escaping (Bool) -> Void) {

        let myAppPassword = "fhwwnbhvqwiocejv"
            let url = URL(string: "https://us-central1-smartinventory-5eba9.cloudfunctions.net/sendEmail")!
            let data = [
                "subject": "Here Is your login Password For your Smart Inventory App",
                "loginMail": "smartinventorygdp@gmail.com",
                "emailFrom": "smartinventorygdp@gmail.com",
                "emailTo": emailTo,
                "appPassword": myAppPassword,
                "body":  body
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error sending email: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                    print("Error sending email: Invalid response")
                    completion(false)
                    return
                }

                print("Email sent successfully")
                completion(true)
            }

            task.resume()
        }
    }
