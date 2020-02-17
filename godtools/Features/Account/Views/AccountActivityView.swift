//
//  AccountActivityView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AccountActivityView: UIView, NibBased {
    
    @IBOutlet weak private var activityCollectionView: UICollectionView!
    
    required init() {
        super.init(frame: UIScreen.main.bounds)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        loadNib()
    }
}
