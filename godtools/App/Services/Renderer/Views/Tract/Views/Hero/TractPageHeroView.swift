//
//  TractPageHeroView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class TractPageHeroView: MobileContentStackView {
    
    private let viewModel: TractPageHeroViewModel
                    
    init(viewModel: TractPageHeroViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: nil, scrollIsEnabled: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - MobileContentView

    override func viewDidAppear(navigationEvent: MobileContentPagesNavigationEvent?) {
        viewModel.heroDidAppear()
    }

    override func viewDidDisappear() {
        viewModel.heroDidDisappear()
    }
}
