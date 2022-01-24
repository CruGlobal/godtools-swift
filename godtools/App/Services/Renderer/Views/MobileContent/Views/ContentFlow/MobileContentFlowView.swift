//
//  MobileContentFlowView.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentFlowView: MobileContentView {
    
    private let viewModel: MobileContentFlowViewModelType
    
    required init(viewModel: MobileContentFlowViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
