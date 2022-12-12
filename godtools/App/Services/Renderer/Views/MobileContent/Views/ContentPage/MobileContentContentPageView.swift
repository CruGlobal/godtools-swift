//
//  MobileContentContentPageView.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentContentPageView: MobileContentPageView {
    
    private let viewModel: MobileContentContentPageViewModel
    private let contentInsets: UIEdgeInsets
    private let itemSpacing: CGFloat
    
    private var contentStackView: MobileContentStackView?
    
    init(viewModel: MobileContentContentPageViewModel, contentInsets: UIEdgeInsets, itemSpacing: CGFloat) {
        
        self.viewModel = viewModel
        self.contentInsets = contentInsets
        self.itemSpacing = itemSpacing
        
        super.init(viewModel: viewModel, nibName: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func renderChild(childView: MobileContentView) {
        super.renderChild(childView: childView)
                
        if let contentStackView = childView as? MobileContentStackView {
            addContentStackView(contentStackView: contentStackView)
        }
    }
    
    override func getPositionState() -> MobileContentViewPositionState {
        
        let scrollVerticalContentOffsetPercentageOfContentSize: CGFloat = contentStackView?.getScrollViewVerticalContentOffsetPercentageOfContentSize() ?? 0
        
        return MobileContentPagePositionState(scrollVerticalContentOffsetPercentageOfContentSize: scrollVerticalContentOffsetPercentageOfContentSize)
    }
    
    override func setPositionState(positionState: MobileContentViewPositionState, animated: Bool) {
        
        guard let contentPagePositionState = positionState as? MobileContentPagePositionState else {
            return
        }
        
        let contentOffsetY: CGFloat = contentPagePositionState.scrollVerticalContentOffsetPercentageOfContentSize
        
        contentStackView?.setScrollViewVerticalContentOffsetPercentageOfContentSize(verticalContentOffsetPercentage: contentOffsetY, animated: animated)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        viewModel.pageDidAppear()
    }
}

extension MobileContentContentPageView {
    
    func addContentStackView(contentStackView: MobileContentStackView) {
        
        guard self.contentStackView == nil else {
            return
        }
        
        addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.constrainEdgesToView(view: self)
        contentStackView.configureLayout(contentInsets: contentInsets, itemSpacing: itemSpacing, scrollIsEnabled: true)
        
        self.contentStackView = contentStackView
    }
}
