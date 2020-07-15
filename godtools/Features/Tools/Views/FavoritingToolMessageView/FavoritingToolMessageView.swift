//
//  FavoritingToolMessageView.swift
//  godtools
//
//  Created by Levi Eggert on 7/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol FavoritingToolMessageViewDelegate: class {
    
    func favoritingToolMessageCloseTapped()
}

class FavoritingToolMessageView: UIView, NibBased {
    
    private var viewModel: FavoritingToolMessageViewModelType?
    
    private weak var delegate: FavoritingToolMessageViewDelegate?
    
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
    
    func configure(viewModel: FavoritingToolMessageViewModelType, delegate: FavoritingToolMessageViewDelegate?) {
        self.viewModel = viewModel
        self.delegate = delegate
        messageLabel.text = viewModel.message
    }
    
    @objc func handleClose(button: UIButton) {
        viewModel?.closeTapped()
        delegate?.favoritingToolMessageCloseTapped()
    }
}
