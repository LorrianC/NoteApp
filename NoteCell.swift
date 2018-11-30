//
//  NoteCell.swift
//  NoteApp
//
//  Created by LorrianC on 2018/11/8.
//  Copyright © 2018 Lorrianc. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    
    @IBOutlet weak var myLabel: UILabel!
    
    @IBOutlet weak var myswitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
