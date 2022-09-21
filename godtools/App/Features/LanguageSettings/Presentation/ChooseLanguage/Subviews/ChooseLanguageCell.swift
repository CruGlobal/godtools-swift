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
    
    private var viewModel: ChooseLanguageCellViewModel?
        
    @IBOutlet weak private var selectedView: UIView!
    @IBOutlet private weak var languageLabel: UILabel!
    @IBOutlet weak private var separatorLine: UIView!
    @IBOutlet weak private var separatorLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak private var separatorRightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    func configure(viewModel: ChooseLanguageCellViewModel) {
        
        self.viewModel = viewModel
        
        languageLabel.text = viewModel.languageName
        
        if let fontSize = viewModel.languageLabelFontSize {
            
            languageLabel.font = UIFont(name: languageLabel.font.fontName, size: CGFloat(fontSize))
        }
        
        selectedView.isHidden = viewModel.hidesSelected
        separatorLine.isHidden = viewModel.hidesSeparator
        
        separatorLeftConstraint.constant = CGFloat(viewModel.separatorLeftInset)
        separatorRightConstraint.constant = CGFloat(viewModel.separatorRightInset)
        
        if let selectorColor = viewModel.selectorColor {
            
            selectedView.backgroundColor = selectorColor
        }
        
        if let separatorColor = viewModel.separatorColor {
            
            separatorLine.backgroundColor = separatorColor
        }
    }
}
