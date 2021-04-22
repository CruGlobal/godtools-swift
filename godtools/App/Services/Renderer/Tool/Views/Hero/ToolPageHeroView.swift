//
//  ToolPageHeroView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolPageHeroView: MobileContentStackView {
    
    private let viewModel: ToolPageHeroViewModelType
                    
    required init(viewModel: ToolPageHeroViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(itemHorizontalInsets: 0, itemSpacing: 20, scrollIsEnabled: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(itemHorizontalInsets: CGFloat, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemHorizontalInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    // MARK: - MobileContentView

    override func viewDidAppear() {

        viewModel.heroDidAppear()
    }

    override func viewDidDisappear() {

        viewModel.heroDidDisappear()
    }
}
