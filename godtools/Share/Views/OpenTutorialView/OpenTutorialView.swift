//
//  OpenTutorialView.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OpenTutorialView: UIView, NibBased {
    
    @IBOutlet weak private var showTutorialLabel: UILabel!
    @IBOutlet weak private var openTutorialButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    func configure(viewModel: OpenTutorialViewModelType) {
        showTutorialLabel.text = viewModel.showTutorialTitle
        openTutorialButton.setTitle(viewModel.openTutorialTitle, for: .normal)
    }
}
