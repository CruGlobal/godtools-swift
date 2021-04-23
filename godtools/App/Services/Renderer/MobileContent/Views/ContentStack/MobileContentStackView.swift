//
//  MobileContentStackView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentStackView: MobileContentView {
    
    private let contentView: UIView = UIView()
    private let itemHorizontalInsets: CGFloat
    private let itemSpacing: CGFloat
    
    private var scrollView: UIScrollView?
    private var lastAddedView: UIView?
    private var lastAddedBottomConstraint: NSLayoutConstraint?
    private var spacerViews: [MobileContentSpacerView] = Array()
            
    required init(itemHorizontalInsets: CGFloat, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
                
        self.itemHorizontalInsets = itemHorizontalInsets
        self.itemSpacing = itemSpacing
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: itemSpacing))
        
        setupConstraints(scrollIsEnabled: scrollIsEnabled)
                
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        scrollView?.backgroundColor = .clear
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {

    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        relayoutForSpacerViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        relayoutForSpacerViews()
    }
    
    // MARK: - MobileContentView

    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        addChildView(childView: childView)
        
        if let accordionView = childView as? MobileContentAccordionView {
            accordionView.setDelegate(delegate: self)
        }
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
    
    var isEmpty: Bool {
        return contentView.subviews.isEmpty
    }
    
    var scrollViewFrame: CGRect? {
        return scrollView?.frame
    }
    
    var contentSize: CGSize {
        return scrollView?.contentSize ?? contentView.frame.size
    }
    
    func setContentSize(size: CGSize) {
        scrollView?.contentSize = size
    }
    
    func getContentInset() -> UIEdgeInsets? {
        return scrollView?.contentInset
    }
    
    func setContentInset(contentInset: UIEdgeInsets) {
        if let scrollView = self.scrollView {
            scrollView.contentInset = contentInset
            relayoutForSpacerViews()
        }
    }
    
    func getContentOffset() -> CGPoint? {
        return scrollView?.contentOffset
    }
    
    func setContentOffset(contentOffset: CGPoint) {
        
        scrollView?.contentOffset = contentOffset
    }
    
    func setScollBarsHidden(hidden: Bool) {
        
        scrollView?.showsVerticalScrollIndicator = !hidden
        scrollView?.showsHorizontalScrollIndicator = !hidden
    }
    
    func setScrollViewDelegate(delegate: UIScrollViewDelegate) {
        scrollView?.delegate = delegate
    }
    
    func contentScrollViewIsEqualTo(otherScrollView: UIScrollView) -> Bool {
        if let contentScrollView = self.scrollView {
            return contentScrollView == otherScrollView
        }
        return false
    }
    
    func scrollToBottomOfContent(animated: Bool) {
        
        guard let scrollView = self.scrollView else {
            return
        }
        
        let bottomOffset = CGPoint(
            x: 0,
            y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom
        )
        
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    func relayoutForSpacerViews() {
                
        guard let parentView = superview else {
            return
        }
        
        guard spacerViews.count > 0 else {
            return
        }
        
        parentView.layoutIfNeeded()
        parentView.superview?.layoutIfNeeded()
                
        let parentHeight: CGFloat = parentView.frame.size.height
        
        var heightOfChildrenAndItemSpacing: CGFloat = 0
        
        for subview in contentView.subviews {
            
            let subviewIsSpacerView: Bool = subview is MobileContentSpacerView
            
            if !subviewIsSpacerView {
                heightOfChildrenAndItemSpacing += subview.frame.size.height
            }
            
            heightOfChildrenAndItemSpacing += itemSpacing
        }
        
        let totalInsetsHeight: CGFloat
        
        if let scrollView = self.scrollView {
            totalInsetsHeight = scrollView.contentInset.top + scrollView.contentInset.bottom
        }
        else {
            totalInsetsHeight = 0
        }
        
        let remainingSpacingHeight: CGFloat = parentHeight - heightOfChildrenAndItemSpacing - totalInsetsHeight
        
        let spacerHeight: CGFloat
        
        if remainingSpacingHeight > 0 {
            spacerHeight = floor(remainingSpacingHeight / CGFloat(spacerViews.count))
        }
        else {
            spacerHeight = 0
        }
        
        for spacerView in spacerViews {
            spacerView.setHeight(height: spacerHeight)
        }
        
        parentView.layoutIfNeeded()
    }
    
    private func addChildView(childView: MobileContentStackChildViewType) {
             
        if let lastAddedBottomConstraint = self.lastAddedBottomConstraint {
            contentView.removeConstraint(lastAddedBottomConstraint)
        }
                
        contentView.addSubview(childView.view)
        
        childView.view.translatesAutoresizingMaskIntoConstraints = false
           
        let constrainLeadingToSuperviewLeading: Bool
        let constrainTrailingToSuperviewTrailing: Bool
        
        switch childView.contentStackHeightConstraintType {
            
        case .constrainedToChildren:
            
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: childView.view,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 20
            )
            
            heightConstraint.priority = UILayoutPriority(500)
            
            childView.view.addConstraint(heightConstraint)
            
        case .equalToHeight(let height):
            
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: childView.view,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: height
            )
            
            heightConstraint.priority = UILayoutPriority(1000)
            
            childView.view.addConstraint(heightConstraint)
            
        case .equalToSize(let size):
            
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = false
            
            let widthConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: childView.view,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: size.width
            )
            
            widthConstraint.priority = UILayoutPriority(1000)
            
            childView.view.addConstraint(widthConstraint)
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: childView.view,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: size.height
            )
            
            heightConstraint.priority = UILayoutPriority(1000)
            
            childView.view.addConstraint(heightConstraint)
            
        case .intrinsic:
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            // Do nothing because view is instrinsic and we use the intrinsic content size.
            break
            
        case .setToAspectRatioOfProvidedSize(let size):
                   
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            let aspectRatio: NSLayoutConstraint = NSLayoutConstraint(
                item: childView.view,
                attribute: .height,
                relatedBy: .equal,
                toItem: childView.view,
                attribute: .width,
                multiplier: size.height / size.width,
                constant: 0
            )
            
            childView.view.addConstraint(aspectRatio)
            
        case .spacer:
           
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            if let spacerView = childView.view as? MobileContentSpacerView {
                
                spacerView.setHeight(height: 0)
                spacerViews.append(spacerView)
            }
            else {
                assertionFailure("Invalid view type for spacer.  View should be of type MobileContentSpacerView.")
            }
        }
        
        if constrainLeadingToSuperviewLeading {
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: childView.view,
                attribute: .leading,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .leading,
                multiplier: 1,
                constant: itemHorizontalInsets
            )
            
            contentView.addConstraint(leading)
        }
        
        if constrainTrailingToSuperviewTrailing {
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: childView.view,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .trailing,
                multiplier: 1,
                constant: itemHorizontalInsets * -1
            )
            
            contentView.addConstraint(trailing)
        }
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: childView.view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        contentView.addConstraint(bottom)
        
        let top: NSLayoutConstraint
        
        if let lastView = lastAddedView {
            
            top = NSLayoutConstraint(
                item: childView.view,
                attribute: .top,
                relatedBy: .equal,
                toItem: lastView,
                attribute: .bottom,
                multiplier: 1,
                constant: itemSpacing
            )
        }
        else {
            
            top = NSLayoutConstraint(
                item: childView.view,
                attribute: .top,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .top,
                multiplier: 1,
                constant: 0
            )
        }
        
        contentView.addConstraint(top)
        
        lastAddedView = childView.view
        lastAddedBottomConstraint = bottom
        
        relayoutForSpacerViews()
    }
}

// MARK: - MobileContentAccordionViewDelegate

extension MobileContentStackView: MobileContentAccordionViewDelegate {
    
    func accordionViewDidChangeSectionViewTextHiddenState(accordionView: MobileContentAccordionView, sectionView: MobileContentSectionView, textIsHidden: Bool, textHeight: CGFloat) {
        
        layoutIfNeeded()
        
        relayoutForSpacerViews()
        
        guard let scrollView = self.scrollView, !textIsHidden else {
            return
        }
        
        let scrollAreaTopY: CGFloat = scrollView.contentOffset.y
        let scrollAreaBottomY: CGFloat = scrollAreaTopY + scrollView.frame.size.height
            
        let accordionTopY: CGFloat = accordionView.frame.origin.y
        let sectionTopY: CGFloat = accordionTopY + sectionView.frame.origin.y
        let sectionBottomY: CGFloat = sectionTopY + sectionView.viewHeight
        
        let sectionAreaOutsideScrollView: CGFloat = sectionBottomY - scrollAreaBottomY
        
        if sectionAreaOutsideScrollView > 0 {
                        
            scrollView.setContentOffset(
                CGPoint(x: 0, y: scrollView.contentOffset.y + sectionAreaOutsideScrollView),
                animated: true
            )
        }
    }
}

// MARK: - Constraints

extension MobileContentStackView {
    
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
