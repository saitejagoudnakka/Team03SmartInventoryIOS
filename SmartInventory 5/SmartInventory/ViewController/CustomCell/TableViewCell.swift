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
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var useridum: UILabel!
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

class TableViewHistoryCell: UITableViewCell {
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var upcNumber: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var userid: UILabel!
    @IBOutlet weak var printBtn: UIButton!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var dateTime: UILabel!
    @IBOutlet weak var packageStatusBtn: UIButton!
    @IBOutlet weak var lblPackageStatus: UILabel!
    @IBOutlet weak var viewPackageStatus: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
