//
//  LessonContentView.swift
//  godtools
//
//  Created by Levi Eggert on 04/08/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonContentView: MobileContentStackView {
    
    private let viewModel: LessonContentViewModelType
                    
    required init(viewModel: LessonContentViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(itemSpacing: 20, scrollIsEnabled: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemSpacing:scrollIsEnabled:) has not been implemented")
    }
}
