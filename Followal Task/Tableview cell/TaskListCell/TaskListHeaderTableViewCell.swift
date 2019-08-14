//
//  TaskListHeaderTableViewCell.swift
//  followal
//
//  Created by Vivek Gadhiya on 10/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit

class TaskListHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblDatePhrase: UILabel!
    @IBOutlet weak var lblOverdueCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
