//
//  TaskAssignTableViewCell.swift
//  followal
//
//  Created by Vivek Gadhiya on 09/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift

class TaskAssignTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    
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
    
    func setDetail(_ contact: AssignUserResponseModel) {
        lblName.text = contact.UserName == "" ? contact.EmailAddress : contact.UserName
        imgUserProfile.sd_setImage(with: (contact.Profile).toURL(), placeholderImage: images.ic_user_placeholder(), options: .highPriority, completed: nil)
    }
    func setDetail(_ contact: UserResponseModel) {
        lblName.text = contact.UserName == "" ? contact.EmailAddress : contact.UserName
        imgUserProfile.sd_setImage(with: (contact.Profile).toURL(), placeholderImage: images.ic_user_placeholder(), options: .highPriority, completed: nil)
    }
}
