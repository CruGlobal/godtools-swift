//
//  TutorialToolsView.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialToolsView: UIView, NibBased {
    
    @IBOutlet weak private var toolImageView: UIImageView!
    @IBOutlet weak private var moreInfoImageView: UIImageView!
    @IBOutlet weak private var moreInfoLabel: UILabel!
    
    required init() {
        super.init(frame: UIScreen.main.bounds)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    func configure(viewModel: TutorialToolsViewModel) {
        moreInfoLabel.text = viewModel.moreInfoTitle
    }
}
