//
//  SubTaskTableViewCell.swift
//  followal
//
//  Created by Vivek Gadhiya on 09/04/19.
//  Copyright © 2019 Vivek Gadhiya. All rights reserved.
//

import UIKit
import RxSwift

class SubTaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }

    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
