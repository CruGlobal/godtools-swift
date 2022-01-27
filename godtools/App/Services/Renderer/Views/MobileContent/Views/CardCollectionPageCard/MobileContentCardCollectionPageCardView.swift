//
//  MobileContentCardCollectionPageCardView.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardCollectionPageCardView: MobileContentView {
    
    private let viewModel: MobileContentCardCollectionPageCardViewModelType
    
    required init(viewModel: MobileContentCardCollectionPageCardViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
