//
//  FavoritingToolMessageView.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class FavoritingToolMessageView: UIView, NibBased {
    
    private var viewModel: FavoritingToolMessageViewModelType?
        
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var closeButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
        closeButton.addTarget(self, action: #selector(handleClose(button:)), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(viewModel: FavoritingToolMessageViewModelType) {
        
        backgroundColor = ColorPalette.banner.uiColor
        
        self.viewModel = viewModel
        messageLabel.text = viewModel.message
        layoutIfNeeded()
    }
    
    @objc func handleClose(button: UIButton) {
        viewModel?.closeTapped()
    }
}
