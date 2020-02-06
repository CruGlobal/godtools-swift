//
//  TutorialInMenuView.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialInMenuView: UIView, NibBased {
    
    @IBOutlet weak private var menuImageView: UIImageView!
    
    required init() {
        super.init(frame: UIScreen.main.bounds)
        loadNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    func configure(viewModel: TutorialInMenuViewModel) {

    }
}
