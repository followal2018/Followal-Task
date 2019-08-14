//
//  CommentTableViewCell.swift
//  Followal Task
//
//  Created by iMac on 03/08/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblHourAgo: UILabel!
    @IBOutlet weak var lblDesc: UILabel!

    @IBOutlet weak var imgUsername: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
