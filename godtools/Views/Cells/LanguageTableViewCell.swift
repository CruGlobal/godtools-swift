//
//  GTLanguageTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol LanguageTableViewCellDelegate {
    func downloadButtonWasPressed(_ cell: LanguageTableViewCell)
    func deleteButtonWasPressed(_ cell: LanguageTableViewCell)
}

class LanguageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var languageLabel: GTLabel!
    
    var cellDelegate: LanguageTableViewCellDelegate?
    var language: Language? {
        didSet {
            guard let language = language else {
                languageExists(false)
                return
            }
            languageExists(language.shouldDownload)
            languageLabel.text = language.localizedName()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }
    
    // MARK: - Actions
    
    @IBAction func pressDownloadButton(_ sender: Any) {
        self.cellDelegate?.downloadButtonWasPressed(self)
        self.languageExists(true)
    }
    
    // MARK: - Helpers
    
    fileprivate func setupStyle() {
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.gtGreen.withAlphaComponent(0.25)
        self.selectedBackgroundView = selectedView
    }
    
    fileprivate func languageExists(_ exists:Bool) {
        self.downloadButton.isHidden = exists
    }
}
