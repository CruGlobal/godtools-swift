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
        
        super.init(itemHorizontalInsets: 30, itemSpacing: 20, scrollIsEnabled: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(itemHorizontalInsets: CGFloat, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemHorizontalInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
}
