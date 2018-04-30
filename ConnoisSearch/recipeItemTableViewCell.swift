//
//  recipeItemTableViewCell.swift
//  ConnoisSearch
//
//  Created by Bharucha, Het S on 4/28/18.
//  Copyright © 2018 group13. All rights reserved.
//

import UIKit

class recipeItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var prepTime: UILabel!
    @IBOutlet weak var recipeTitle: UILabel!
    var uid: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
