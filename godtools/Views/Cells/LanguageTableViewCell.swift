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
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var languageLabel: GTLabel!
    
    var cellDelegate: LanguageTableViewCellDelegate?
    var language: Language? {
        didSet {
            languageExists(language!.shouldDownload)
            languageCanBeDeleted(language: language!)
            languageLabel.text = language!.localizedName()
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
    
    @IBAction func pressDeleteButton(_ sender: Any) {
        self.cellDelegate?.deleteButtonWasPressed(self)
        self.languageExists(false)
    }
    
    // MARK: - Helpers
    
    fileprivate func setupStyle() {
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.gtGreen.withAlphaComponent(0.25)
        self.selectedBackgroundView = selectedView
    }
    
    fileprivate func languageExists(_ exists:Bool) {
        self.deleteButton.isHidden = !exists
        self.downloadButton.isHidden = exists
    }
    
    fileprivate func languageCanBeDeleted(language: Language) {
        let id = language.remoteId
        let code = language.code
        
        let isPrimary = id == GTSettings.shared.primaryLanguageId
        let isParallel = id == GTSettings.shared.parallelLanguageId
        let isLocale = code == Locale.current.languageCode!
        
        if isPrimary || isParallel || isLocale {
            self.deleteButton.isEnabled = false
            self.downloadButton.isEnabled = false
        } else {
            self.deleteButton.isEnabled = true
            self.downloadButton.isEnabled = true
        }
    }
}
