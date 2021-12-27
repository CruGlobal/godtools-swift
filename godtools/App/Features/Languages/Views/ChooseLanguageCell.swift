//
//  ChooseLanguageCell.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ChooseLanguageCell: UITableViewCell {
    
    static let nibName: String = "ChooseLanguageCell"
    static let reuseIdentifier: String = "ChooseLanguageCellReuseIdentifier"
    
    private var viewModel: ChooseLanguageCellViewModelType?
        
    @IBOutlet weak private var selectedView: UIView!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet weak private var downloadImageView: UIImageView!
    @IBOutlet weak private var selectorView: UIView!
    @IBOutlet weak private var separatorLine: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    func configure(viewModel: ChooseLanguageCellViewModelType) {
        
        self.viewModel = viewModel
        
        languageLabel.text = viewModel.languageName
        downloadImageView.isHidden = viewModel.languageIsDownloaded
        selectedView.isHidden = viewModel.hidesSelected
        separatorLine.isHidden = viewModel.hidesSeparator
        
        if let selectorColor = viewModel.selectorColor {
            
            selectorView.backgroundColor = selectorColor
        }
        
        if let separatorColor = viewModel.separatorColor {
            
            separatorLine.backgroundColor = separatorColor
        }
    }
}
