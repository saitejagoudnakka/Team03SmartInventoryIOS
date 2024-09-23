//
//  TableViewCell.swift
//  SmartInventory
//
//  Created by Macbook-Pro on 12/09/24.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var upcNumber: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var userid: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
