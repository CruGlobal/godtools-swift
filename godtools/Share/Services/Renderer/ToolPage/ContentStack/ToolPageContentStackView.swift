//
//  ToolPageContentStackView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentStackView: UIView {
    
    private let viewModel: ToolPageContentStackViewModel
    private let contentView: UIView = UIView()
    
    private var scrollView: UIScrollView?
    private var lastAddedView: UIView?
    private var lastAddedBottomConstraint: NSLayoutConstraint?
        
    required init(viewModel: ToolPageContentStackViewModel) {
                
        self.viewModel = viewModel
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: viewModel.itemSpacing))
        
        setupConstraints(scrollIsEnabled: viewModel.scrollIsEnabled)
                
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView?.backgroundColor = .clear
        
        viewModel.render { [weak self] (mobileContentView: MobileContentView) in
            self?.addContentView(mobileContentView: mobileContentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    var isEmpty: Bool {
        return contentView.subviews.isEmpty
    }
    
    func setContentInset(contentInset: UIEdgeInsets) {
        
        scrollView?.contentInset = contentInset
    }
    
    func setContentOffset(contentOffset: CGPoint) {
        
        scrollView?.contentOffset = contentOffset
    }
    
    func setScollBarsHidden(hidden: Bool) {
        
        scrollView?.showsVerticalScrollIndicator = !hidden
        scrollView?.showsHorizontalScrollIndicator = !hidden
    }
    
    func contentScrollViewIsEqualTo(otherScrollView: UIScrollView) -> Bool {
        if let contentScrollView = self.scrollView {
            return contentScrollView == otherScrollView
        }
        return false
    }
    
    func addContentView(mobileContentView: MobileContentView) {
             
        if let stackView = mobileContentView.view as? ToolPageContentStackView {
            let scrollIsEnabled: Bool = stackView.scrollView?.isScrollEnabled ?? false
            if scrollIsEnabled {
                assertionFailure("\n ToolPageContentStackView: addContentView() Failed to add stackView because scrollIsEnabled is set to true.  Adding stackViews within stackViews scrolling should not be enabled on child stackViews.")
            }
        }
        
        if let lastAddedBottomConstraint = self.lastAddedBottomConstraint {
            contentView.removeConstraint(lastAddedBottomConstraint)
        }
                
        contentView.addSubview(mobileContentView.view)
        
        mobileContentView.view.translatesAutoresizingMaskIntoConstraints = false
           
        switch mobileContentView.heightConstraintType {
            
        case .constrainedToChildren:
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: mobileContentView.view,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 20
            )
            
            heightConstraint.priority = UILayoutPriority(500)
            
            mobileContentView.view.addConstraint(heightConstraint)
            
        case .equalToFrame:
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: mobileContentView.view,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: mobileContentView.view.frame.size.height
            )
            
            heightConstraint.priority = UILayoutPriority(1000)
            
            mobileContentView.view.addConstraint(heightConstraint)
            
        case .intrinsic:
            // Do nothing because view is instrinsic and we use the intrinsic content size.
            break
            
        case .setToAspectRatioOfProvidedSize(let size):
                        
            let aspectRatio: NSLayoutConstraint = NSLayoutConstraint(
                item: mobileContentView.view,
                attribute: .height,
                relatedBy: .equal,
                toItem: mobileContentView.view,
                attribute: .width,
                multiplier: size.height / size.width,
                constant: 0
            )
            
            mobileContentView.view.addConstraint(aspectRatio)
        }
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: mobileContentView.view,
            attribute: .leading,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: mobileContentView.view,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: mobileContentView.view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        let top: NSLayoutConstraint
        
        if let lastView = lastAddedView {
            
            top = NSLayoutConstraint(
                item: mobileContentView.view,
                attribute: .top,
                relatedBy: .equal,
                toItem: lastView,
                attribute: .bottom,
                multiplier: 1,
                constant: viewModel.itemSpacing
            )
        }
        else {
            
            top = NSLayoutConstraint(
                item: mobileContentView.view,
                attribute: .top,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .top,
                multiplier: 1,
                constant: 0
            )
        }
        
        contentView.addConstraint(leading)
        contentView.addConstraint(trailing)
        contentView.addConstraint(bottom)
        contentView.addConstraint(top)
        
        lastAddedView = mobileContentView.view
        lastAddedBottomConstraint = bottom
    }
}

// MARK: - Constraints

extension ToolPageContentStackView {
    
    private func setupConstraints(scrollIsEnabled: Bool) {
            
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        if scrollIsEnabled {
            
            let scrollView: UIScrollView = UIScrollView()
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(scrollView)
            scrollView.addSubview(contentView)
            
            constrainViewEdgesToSuperview(view: scrollView)
            constrainViewEdgesToSuperview(view: contentView)
                        
            let equalWidths: NSLayoutConstraint = NSLayoutConstraint(
                item: scrollView,
                attribute: .width,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .width,
                multiplier: 1,
                constant: 0
            )
            
            scrollView.addConstraint(equalWidths)
            
            self.scrollView = scrollView
        }
        else {
            
            addSubview(contentView)
            
            constrainViewEdgesToSuperview(view: contentView)
        }
    }
    
    private func constrainViewEdgesToSuperview(view: UIView) {
        
        guard let superview = view.superview else {
            return
        }
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .leading,
            relatedBy: .equal,
            toItem: superview,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: superview,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .top,
            relatedBy: .equal,
            toItem: superview,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: superview,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        superview.addConstraint(leading)
        superview.addConstraint(trailing)
        superview.addConstraint(top)
        superview.addConstraint(bottom)
    }
}
