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
    @IBOutlet private weak var downloadButton: UIButton!
    @IBOutlet weak private var separatorLine: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        downloadButton.isUserInteractionEnabled = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    func configure(viewModel: ChooseLanguageCellViewModelType) {
        
        self.viewModel = viewModel
        
        languageLabel.text = viewModel.languageName
        downloadButton.isHidden = viewModel.hidesDownloadButton
        selectedView.isHidden = viewModel.hidesSelected
        separatorLine.isHidden = viewModel.hidesSeparator
    }
}
