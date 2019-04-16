//
//  InputTableViewCell.swift
//  Shield For Dementia Carer
//
//  Created by Xiaocheng Peng on 13/4/19.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit

class InputTableViewCell: UITableViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var indicator: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
