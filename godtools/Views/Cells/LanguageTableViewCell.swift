//
//  GTLanguageTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Actions
    
    @IBAction func pressDownloadButton(_ sender: Any) {
    }
    
    @IBAction func pressDeleteButton(_ sender: Any) {
    }
    
    // MARK: - Helpers
    
    func languageExist(exist:Bool) {
        if exist {
            self.deleteButton.isHidden = false
            self.downloadButton.isHidden = true
        }
        else {
            self.deleteButton.isHidden = true
            self.downloadButton.isHidden = false
        }
    }
    
}
