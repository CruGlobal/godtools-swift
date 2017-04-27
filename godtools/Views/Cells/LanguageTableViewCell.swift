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
    @IBOutlet weak var languageLabel: GTLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
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
    
    fileprivate func setupStyle() {
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.gtGreen.withAlphaComponent(0.25)
        self.selectedBackgroundView = selectedView
    }
    
    func languageExists(_ exists:Bool) {
        self.deleteButton.isHidden = !exists
        self.downloadButton.isHidden = exists
    }
    
}
