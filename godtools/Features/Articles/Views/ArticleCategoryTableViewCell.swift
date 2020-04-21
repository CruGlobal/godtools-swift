//
//  ArticleCategoryTableViewCell.swift
//  godtools
//
//  Created by Igor Ostriz on 14/12/2018.
//  Copyright © 2018 Cru. All rights reserved.
//

import UIKit

class ArticleCategoryTableViewCell: UITableViewCell {

    static let cellID = "ArticleCellID"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    var articleData: ArticleData? {
        didSet {
            titleLabel.text = articleData?.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
