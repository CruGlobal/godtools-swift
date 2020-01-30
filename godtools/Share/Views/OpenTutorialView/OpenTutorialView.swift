//
//  OpenTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol OpenTutorialViewDelegate: class {
    func openTutorialViewCloseTapped(openTutorial: OpenTutorialView)
}

class OpenTutorialView: UIView, NibBased {
    
    private var viewModel: OpenTutorialViewModelType?
    
    private weak var delegate: OpenTutorialViewDelegate?
    
    @IBOutlet weak private var showTutorialLabel: UILabel!
    @IBOutlet weak private var openTutorialButton: UIButton!
    @IBOutlet weak private var closeButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
        openTutorialButton.addTarget(self, action: #selector(handleOpenTutorial(button:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(handleClose(button:)), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        openTutorialButton.centerTitleAndSetImageRightOfTitleWithSpacing(spacing: 16)
    }
    
    func configure(viewModel: OpenTutorialViewModelType, delegate: OpenTutorialViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        showTutorialLabel.text = viewModel.showTutorialTitle
        openTutorialButton.setTitle(viewModel.openTutorialTitle, for: .normal)
    }
    
    @objc func handleClose(button: UIButton) {
        delegate?.openTutorialViewCloseTapped(openTutorial: self)
    }
    
    @objc func handleOpenTutorial(button: UIButton) {
        viewModel?.openTutorialTapped()
    }
}
