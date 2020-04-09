//
//  ArticleTableViewCell.swift
//  godtools
//
//  Created by Igor Ostriz on 15/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    
    static let cellID = "articleCellID"

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var category:XMLArticleCategory?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
