 
import UIKit

class ChatListVC: BaseVC, UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
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
      
        FireStoreManager.shared.getChatList(userEmail: UserDefaultsManager.shared.getEmail()) { (documents, error) in
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
                }
                
                self.messages = messages
                self.shortMessages()
                self.tableView.reloadData()
                
            }
        }
    }
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatList", for: indexPath) as! ChatList
        cell.setData(message:self.messages[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = self.messages[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.chatID = message.chatId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
