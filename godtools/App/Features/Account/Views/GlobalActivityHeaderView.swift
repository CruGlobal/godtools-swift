//
//  GlobalActivityHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 2/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class GlobalActivityHeaderView: UICollectionReusableView {
    
    static let nibName: String = "GlobalActivityHeaderView"
    static let reuseIdentifier: String = "GlobalActivityHeaderViewReuseIdentifier"
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    func configure(viewModel: GlobalActivityHeaderViewModel) {
        titleLabel.text = viewModel.headerTitle
    }
}
