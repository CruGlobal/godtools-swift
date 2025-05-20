//
//  MobileContentStackView.swift
//  godtools
//
//  Created by Levi Eggert on 5/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentStackView: MobileContentView {
    
    private let composeViewController: UIViewController
    
    init(viewModel: MobileContentViewModel, contentInsets: UIEdgeInsets?, scrollIsEnabled: Bool, itemSpacing: CGFloat? = nil) {
              
        let content: [Content] = (viewModel.baseModels as? [Content]) ?? Array()
        
        composeViewController = ContentStackViewKt.ContentStackView(content: content)
                
        super.init(viewModel: viewModel, frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0))

        let composeView: UIView = composeViewController.view
        composeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(composeView)
        composeView.constrainEdgesToView(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - MobileContentView
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        let bounds: CGRect = composeViewController.view.bounds
        print("\n *** Compose Bounds: \(bounds)")
        return .equalToHeight(height: bounds.size.height)
    }
    
    // MARK: -
    
    var contentSize: CGSize {
        return composeViewController.view.bounds.size
    }
    
    var scrollViewFrame: CGRect? {
        return nil
    }
    
    func getScrollViewContentOffset() -> CGPoint? {
        return nil
    }
    
    func getScrollViewContentInset() -> UIEdgeInsets? {
        return nil
    }
    
    func setScrollViewDelegate(delegate: UIScrollViewDelegate) {

    }
    
    func setScrollViewContentSize(size: CGSize) {

    }
    
    func setScrollViewContentInset(contentInset: UIEdgeInsets) {

    }
    
    func getScrollViewVerticalContentOffsetPercentageOfContentSize() -> CGFloat {
       return 0
    }
    
    func setScrollViewVerticalContentOffsetPercentageOfContentSize(verticalContentOffsetPercentage: CGFloat, animated: Bool) {
        
    }
    
    func contentScrollViewIsEqualTo(otherScrollView: UIScrollView) -> Bool {
        return false
    }
}
