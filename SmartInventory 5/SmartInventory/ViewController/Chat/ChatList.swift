 
import UIKit

class ChatList: UITableViewCell {

   // @IBOutlet weak var name: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    @IBOutlet weak var countView: UIView!

    override func awakeFromNib() {
        container.dropShadow(shadowRadius:10)
    }
    
    func setData(message:MessageModel){
        
        print(message)
      //  self.name.text  = "Name - \(message.senderName)"
        self.email.text  = "Email - \(message.sender)"
        self.time.text  = message.dateSent.getTimeOnly()
        self.message.text  = message.text
        countView.layer.cornerRadius = 15.0
        countView.clipsToBounds = true
    }
    
    func updateUnreadCount(_ count: Int) {
        countView.isHidden = (count == 0)
        unreadCountLabel.text = count > 0 ? "\(count)" : nil
    }
}
