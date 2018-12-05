//
//  TableViewCell.swift
//  apis-conex-red
//
//  Created by Dev1 on 29/11/2018.
//  Copyright © 2018 Dev1. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

   @IBOutlet weak var imagen: UIImageView!
   @IBOutlet weak var titulo: UILabel!
   @IBOutlet weak var caption: UILabel!
   
   override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
   
}
