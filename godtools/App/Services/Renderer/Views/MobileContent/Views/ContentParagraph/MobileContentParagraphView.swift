//
//  MobileContentParagraphView.swift
//  godtools
//
//  Created by Levi Eggert on 12/3/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentParagraphView: MobileContentStackView {
    
    private static let topPadding: CGFloat = 8
    private static let bottomPadding: CGFloat = 8
    
    private let viewModel: MobileContentParagraphViewModel
    
    init(viewModel: MobileContentParagraphViewModel, scrollIsEnabled: Bool) {
        
        self.viewModel = viewModel
        
        super.init(
            viewModel: viewModel,
            contentInsets: UIEdgeInsets(top: Self.topPadding, left: 0, bottom: Self.bottomPadding, right: 0),
            scrollIsEnabled: scrollIsEnabled
        )
        
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBinding() {
        
        viewModel.visibilityState.addObserver(self) { [weak self] (visibilityState: MobileContentViewVisibilityState) in
            self?.setVisibilityState(visibilityState: visibilityState)
        }
    }
}
