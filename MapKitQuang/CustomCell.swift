//
//  CustomCell.swift
//  MapKitQuang
//
//  Created by Quang Nguyen on 6/20/16.
//  Copyright © 2016 Quang Nguyen. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    

    @IBOutlet weak var routeID: UILabel!

    @IBOutlet weak var routeDes: UILabel!

    @IBOutlet weak var routeInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
