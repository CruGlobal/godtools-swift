//
//  ToolPageHeroView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolPageHeroView: MobileContentStackView {
    
    private let viewModel: ToolPageHeroViewModel
                    
    init(viewModel: ToolPageHeroViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: .zero, itemSpacing: 20, scrollIsEnabled: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - MobileContentView

    override func viewDidAppear() {
        viewModel.heroDidAppear()
    }

    override func viewDidDisappear() {
        viewModel.heroDidDisappear()
    }
}
