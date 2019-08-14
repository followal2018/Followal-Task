//
//  UserReminderHeaderTableViewCell.swift
//  followal
//
//  Created by Vivek Gadhiya on 11/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit

class UserReminderHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var lblRemindDate: UILabel!
    @IBOutlet weak var lblRepeatReminder: UILabel!
    @IBOutlet weak var lblStopRemider: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
