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
    
    func setContentInset(contentInset: UIEdgeInsets) {
        
        scrollView?.contentInset = contentInset
    }
    
    func setContentOffset(contentOffset: CGPoint) {
        
        scrollView?.contentOffset = contentOffset
    }
    
    func addContentView(view: UIView) {
               
        if let lastAddedBottomConstraint = self.lastAddedBottomConstraint {
            contentView.removeConstraint(lastAddedBottomConstraint)
        }
        
        let lastView: UIView = lastAddedView ?? contentView

        contentView.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let viewIsIntrinsic: Bool = view is UILabel
        
        if let stackView = view as? ToolPageContentStackView {
            
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
        else if !viewIsIntrinsic {
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: view,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: view.frame.size.height
            )
            
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
        
        if lastView != contentView {
            
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
