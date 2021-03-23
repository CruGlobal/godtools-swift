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
        
        super.init(itemSpacing: 20, scrollIsEnabled: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    // MARK: - MobileContentView

    override func viewDidAppear() {

        viewModel.heroDidAppear()
    }

    override func viewDidDisappear() {

        viewModel.heroDidDisappear()
    }
}
