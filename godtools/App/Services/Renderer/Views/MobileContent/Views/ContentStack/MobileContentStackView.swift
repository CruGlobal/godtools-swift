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
              
        print("\n ***** MobileContentStackView init() ***** ")
        
        let content: [Content] = (viewModel.baseModels as? [Content]) ?? Array()
        let resourcesDir: String = viewModel.renderedPageContext.resourcesCache.getRootDirectory()?.path ?? ""
        let fileSystem = ResourcesFileSystemKt.ResourcesFileSystem(directory: resourcesDir)

        composeViewController = ContentStackViewKt.ContentStackView(content: content, state: viewModel.rendererState, fileSystem: fileSystem)

        print("  content: \(content.count)")
        print("  composeView.bounds: \(composeViewController.view.bounds)")
                
        super.init(viewModel: viewModel, frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))

        let composeView: UIView = composeViewController.view
        //composeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(composeView)
        composeView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        frame = UIScreen.main.bounds
        //composeView.constrainEdgesToView(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - MobileContentView
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        //let bounds: CGRect = composeViewController.view.bounds
        //print("\n *** Compose Bounds: \(bounds)")
        return .equalToHeight(height: UIScreen.main.bounds.size.height)
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
