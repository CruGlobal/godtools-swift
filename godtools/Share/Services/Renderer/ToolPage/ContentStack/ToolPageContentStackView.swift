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
        
        super.init(frame: .zero)
        
        setupConstraints(scrollIsEnabled: viewModel.scrollIsEnabled)
                
        scrollView?.backgroundColor = .clear
        
        viewModel.render { [weak self] (view: UIView) in
            self?.addContentView(view: view)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
    
    func addContentView(view: UIView) {
               
        if let lastAddedBottomConstraint = self.lastAddedBottomConstraint {
            contentView.removeConstraint(lastAddedBottomConstraint)
        }
        
        contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
                
        if view is UILabel {
             // Do nothing because view is instrinsic and we use the intrinsic content size.
        }
        else if let stackView = view as? ToolPageContentStackView {
            
            let scrollIsEnabled: Bool = stackView.scrollView?.isScrollEnabled ?? false
            if scrollIsEnabled {
                assertionFailure("\n ToolPageContentStackView: addContentView() Failed to add stackView because scrollIsEnabled is set to true.  Adding stackViews within stackViews scrolling should not be enabled on child stackViews.")
            }
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: stackView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: view.frame.size.height
            )
            
            heightConstraint.priority = UILayoutPriority(500)
            
            stackView.addConstraint(heightConstraint)
        }
        else if let imageView = view as? UIImageView {
            
            let imageSize: CGSize = imageView.image?.size ?? CGSize(width: contentView.bounds.size.width, height: contentView.bounds.size.width)
            
            let aspectRatio: NSLayoutConstraint = NSLayoutConstraint(
                item: imageView,
                attribute: .height,
                relatedBy: .equal,
                toItem: imageView,
                attribute: .width,
                multiplier: imageSize.height / imageSize.width,
                constant: 0
            )
            
            imageView.addConstraint(aspectRatio)
        }
        else if view is ToolPageContentTabsView || view is ToolPageContentInputView || view is ToolPageContentFormView || view is ToolPageModalView {
            
            // TODO: ~Levi
            //  Maybe we can replace the passed in UIView with a protocol that defines how the view is added to the content stack.
            //  We wouldn't need to check against types because the protocol would provide it.
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: view,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 20
            )
            
            heightConstraint.priority = UILayoutPriority(500)
            
            view.addConstraint(heightConstraint)
        }
        else {
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: view,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: view.frame.size.height
            )
            
            heightConstraint.priority = UILayoutPriority(1000)
            
            view.addConstraint(heightConstraint)
        }
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .leading,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: view,
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
                item: view,
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
                item: view,
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
        
        lastAddedView = view
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
