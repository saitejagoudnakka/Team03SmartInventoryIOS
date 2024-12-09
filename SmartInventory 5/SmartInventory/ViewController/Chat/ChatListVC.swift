 
import UIKit
import FirebaseFirestore

class ChatListVC: BaseVC, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var unreadCounts = [String: Int]()

    var messages = [MessageModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the data source for the tableView
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "ChatList", bundle: nil), forCellReuseIdentifier: "ChatList")
 
        getMessages()
    }
    
    
    func shortMessages() {
        messages = messages.sorted(by: {
            $0.getDate().compare($1.getDate()) == .orderedDescending
        })
    }
    
    func getMessages() {
      
        FireStoreManager.shared.getChatList { (documents, error) in
            if let error = error {
                // Handle the error
                print("Error retrieving messages: \(error)")
            } else if let documents = documents {
                // Create an array to store MessageModel instances
                var messages = [MessageModel]()
                
                for document in documents {
                    let data = document.data()
                    
                    // Create a MessageModel instance from Firestore data
                    let message = MessageModel(data: data)
                    
                    // Append the message to the array
                    messages.append(message)
                    self.fetchUnreadCount(chatID: message.chatId)

                }
                
                self.messages = messages
                self.shortMessages()
                self.tableView.reloadData()
                
            }
        }
    }
    
   
    func fetchUnreadCount(chatID: String) {
        let chatRef = Firestore.firestore().collection("Chat").document(chatID)
        chatRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot, document.exists else {
                print("Error listening to unread count changes:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            if let unreadCountData = document.data()?["unreadCount"] as? [String: Any] {
                let userEmail = UserDefaultsManager.shared.getEmail()
                let emailParts = userEmail.components(separatedBy: "@")
                
                if emailParts.count == 2 {
                    let emailKey = emailParts[0] + "@" + emailParts[1].components(separatedBy: ".").first!
                    
                    if let userCounts = unreadCountData[emailKey] as? [String: Any],
                       let userUnreadCount = userCounts["com"] as? Int {
                        self.unreadCounts[chatID] = userUnreadCount
                        print("Updated unread count for \(userEmail):", userUnreadCount)
                        
                        self.tableView.reloadData()
                    } else {
                        self.unreadCounts[chatID] = 0
                    }
                } else {
                    print("Email format issue or parsing error for userEmail:", userEmail)
                    self.unreadCounts[chatID] = 0
                }
            } else {
                self.unreadCounts[chatID] = 0
            }
        }
    }
    
    func reloadCellForChatID(_ chatID: String) {
        if let row = messages.firstIndex(where: { $0.chatId == chatID }) {
            let indexPath = IndexPath(row: row, section: 0)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatList", for: indexPath) as! ChatList
        let message = messages[indexPath.row]
        
        // Set the data for the cell, including unread count
        cell.setData(message: message)
        let unreadCount = unreadCounts[message.chatId] ?? 0
        cell.updateUnreadCount(unreadCount)

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = self.messages[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.chatID = message.chatId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
