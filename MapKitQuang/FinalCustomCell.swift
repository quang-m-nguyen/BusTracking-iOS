//
//  FinalCustomCell.swift
//  MapKitQuang
//
//  Created by Quang Nguyen on 6/21/16.
//  Copyright © 2016 Quang Nguyen. All rights reserved.
//

import UIKit

class FinalCustomCell: UITableViewCell {

   
    @IBOutlet var remainTime: UILabel!
    @IBOutlet var busTime: UILabel!
    @IBOutlet var busName: UILabel!
    @IBOutlet var busDes: UILabel!
    @IBOutlet var busImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
