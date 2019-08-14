//
//  TaskFolderListTableViewCell.swift
//  followal
//
//  Created by Vivek Gadhiya on 08/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit

class TaskFolderListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgFolderType: UIImageView!
    @IBOutlet weak var lblFolderName: UILabel!
    @IBOutlet weak var lblTaskCount: UILabel!
    @IBOutlet weak var lblOverDueCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
