//
//  BalanceTableViewCell.swift
//  jenniferbuur_pset6
//
//  Created by Jennifer Buur on 19-03-17.
//  Copyright © 2017 Jennifer Buur. All rights reserved.
//

import UIKit

class BalanceTableViewCell: UITableViewCell {

    @IBOutlet var memberName: UILabel!
    @IBOutlet var balanceMember: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
