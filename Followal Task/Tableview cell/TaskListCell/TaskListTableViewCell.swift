//
//  TaskListTableViewCell.swift
//  followal
//
//  Created by Vivek Gadhiya on 08/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift

class TaskListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTaskName: UILabel!
    @IBOutlet weak var btnBookMark: UIButton!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var btnSubTaskList: UIButton!
    @IBOutlet weak var btnComment: UIButton!

    @IBOutlet weak var imgDueDate: UIImageView!

    @IBOutlet weak var lblDueDate: UILabel!
    @IBOutlet weak var imgReminderDate: UIImageView!
    @IBOutlet weak var lblReminderDate: UILabel!
    
    @IBOutlet weak var lblAttchmentCount: UILabel!
    @IBOutlet weak var lblUserCount: UILabel!
    @IBOutlet weak var lblCommentCount: UILabel!
    
    @IBOutlet weak var lblHeaderDate: UILabel!
    @IBOutlet weak var lblHeaderOverdue: UILabel!

    @IBOutlet weak var constraintHeaderHeight: NSLayoutConstraint!

    var disposeBag = DisposeBag()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
