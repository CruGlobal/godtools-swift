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
        
        let contentHorizontalInsets: CGFloat = 30
        
        super.init(
            contentInsets: UIEdgeInsets(top: 0, left: contentHorizontalInsets, bottom: 0, right: contentHorizontalInsets),
            itemSpacing: 20,
            scrollIsEnabled: true
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(contentInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
}
