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
    @IBOutlet private weak var languageLabel: GTLabel!
    @IBOutlet private weak var downloadButton: UIButton!
        
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
        
        viewModel.languageText.addObserver(self) { [weak self] (text: String) in
            self?.languageLabel.text = text
        }
        
        viewModel.hidesDownloadButton.addObserver(self) { [weak self] (hidden: Bool) in
            self?.downloadButton.isHidden = hidden
        }
        
        selectedView.isHidden = viewModel.hidesSelected
    }
}
