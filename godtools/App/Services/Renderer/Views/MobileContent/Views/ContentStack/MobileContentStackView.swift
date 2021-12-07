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
    private let contentInsets: UIEdgeInsets
    private let itemSpacing: CGFloat
    
    private var scrollView: UIScrollView?
    private var childViews: [MobileContentView] = Array()
    private var lastAddedView: MobileContentView?
    private var lastAddedBottomConstraint: NSLayoutConstraint?
    private var autoSpacerViews: [MobileContentSpacerView] = Array()
            
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
                
        self.contentInsets = contentInsets
        self.itemSpacing = itemSpacing
        
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: itemSpacing))
        
        setupConstraints(scrollIsEnabled: scrollIsEnabled)
                
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        if scrollIsEnabled && scrollView == nil {
            assertionFailure("ScrollView should be initialized at this point.")
        }
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
        
        childView.drawBorder(color: .green)
        
        addChildView(childView: childView)
        
        if let accordionView = childView as? MobileContentAccordionView {
            accordionView.setDelegate(delegate: self)
        }
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
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
    
    func setContentBackgroundColor(color: UIColor) {
        contentView.backgroundColor = color
    }
    
    func setContentCornerRadius(cornerRadius: CGFloat) {
        contentView.layer.cornerRadius = cornerRadius
    }
    
    func setContentClipsToBounds(clipsToBounds: Bool) {
        contentView.clipsToBounds = clipsToBounds
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
    
    override func childViewDidChangeVisibilityState(childView: MobileContentView, previousVisibilityState: MobileContentViewVisibilityState, visibilityState: MobileContentViewVisibilityState) {
        
        super.childViewDidChangeVisibilityState(childView: childView, previousVisibilityState: previousVisibilityState, visibilityState: visibilityState)
        
        guard previousVisibilityState != visibilityState else {
            return
        }
        
        switch visibilityState {
        
        case .gone:
            childView.isHidden = true
            
        case .hidden:
            childView.isHidden = true
            
        case .visible:
            childView.isHidden = false
        }
        
        if visibilityState == .gone || previousVisibilityState == .gone {
            relayoutTopAndBottomConstraintsForChildViews()
        }
    }
    
    private func addAutoSpacerView(spacerView: MobileContentSpacerView) {
        
        guard spacerView.mode == .auto else {
            assertionFailure("Only spacer's with mode auto can be added.")
            return
        }
        
        spacerView.setHeight(height: 0)
        autoSpacerViews.append(spacerView)
    }
}

// MARK: - Update Layout For Spacer Views

extension MobileContentStackView {
    
    func relayoutForSpacerViews() {
                
        guard let parentView = superview else {
            return
        }
        
        guard autoSpacerViews.count > 0 else {
            return
        }
        
        parentView.layoutIfNeeded()
        parentView.superview?.layoutIfNeeded()
                
        let parentHeight: CGFloat = parentView.frame.size.height
        
        var heightOfChildrenAndItemSpacing: CGFloat = 0
        
        for childView in childViews {
            
            let isSpacerView: Bool = childView is MobileContentSpacerView
            
            if !isSpacerView && childView.visibilityState != .gone {
                
                heightOfChildrenAndItemSpacing += childView.frame.size.height
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
            spacerHeight = floor(remainingSpacingHeight / CGFloat(autoSpacerViews.count))
        }
        else {
            spacerHeight = 0
        }
        
        for spacerView in autoSpacerViews {
            spacerView.setHeight(height: spacerHeight)
        }
        
        parentView.layoutIfNeeded()
    }
}

// MARK: - Content Stack Child Constraints

extension MobileContentStackView {
    
    private func addChildView(childView: MobileContentView) {
             
        let childContentView: UIView = childView
                      
        contentView.addSubview(childContentView)
        
        childViews.append(childView)
                
        childContentView.translatesAutoresizingMaskIntoConstraints = false
           
        addLeadingTrailingAndHeightConstraintsToChildView(childView: childView)
        
        addTopAndBottomConstraintsToChildView(childView: childView)
        
        relayoutForSpacerViews()
    }
    
    private func relayoutTopAndBottomConstraintsForChildViews() {
        
        lastAddedView = nil
        lastAddedBottomConstraint = nil
        
        let contentViewConstraints: [NSLayoutConstraint] = contentView.constraints
        
        for index in stride(from: contentViewConstraints.count - 1, through: 0, by: -1) {
            
            let constraint: NSLayoutConstraint = contentViewConstraints[index]
            
            if constraint.firstAttribute == .top || constraint.firstAttribute == .bottom {
                contentView.removeConstraint(constraint)
            }
        }
        
        for childView in childViews {
            if childView.visibilityState == .visible {
                addTopAndBottomConstraintsToChildView(childView: childView)
            }
        }
        
        contentView.layoutIfNeeded()
        
        relayoutForSpacerViews()
    }
    
    private func addLeadingTrailingAndHeightConstraintsToChildView(childView: MobileContentView) {
        
        let constrainLeadingToSuperviewLeading: Bool
        let constrainTrailingToSuperviewTrailing: Bool
        
        switch childView.heightConstraintType {
            
        case .constrainedToChildren:
            
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 20
            )
            
            heightConstraint.priority = UILayoutPriority(500)
            
            childView.addConstraint(heightConstraint)
            
        case .equalToHeight(let height):
            
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: height
            )
            
            heightConstraint.priority = UILayoutPriority(1000)
            
            childView.addConstraint(heightConstraint)
            
        case .equalToSize(let size):
            
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = false
            
            let widthConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .width,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: size.width
            )
            
            widthConstraint.priority = UILayoutPriority(1000)
            
            childView.addConstraint(widthConstraint)
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: size.height
            )
            
            heightConstraint.priority = UILayoutPriority(1000)
            
            childView.addConstraint(heightConstraint)
            
        case .intrinsic:
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            // Do nothing because view is instrinsic and we use the intrinsic content size.
            break
            
        case .setToAspectRatioOfProvidedSize(let size):
                   
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            let aspectRatio: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .height,
                relatedBy: .equal,
                toItem: childView,
                attribute: .width,
                multiplier: size.height / size.width,
                constant: 0
            )
            
            childView.addConstraint(aspectRatio)
            
        case .spacer:
           
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            if let spacerView = childView as? MobileContentSpacerView {
                                
                if spacerView.mode == .auto {
                    addAutoSpacerView(spacerView: spacerView)
                }
            }
            else {
                assertionFailure("Invalid view type for spacer.  View should be of type MobileContentSpacerView.")
            }
        }
        
        if constrainLeadingToSuperviewLeading {
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .leading,
                multiplier: 1,
                constant: contentInsets.left
            )
            
            contentView.addConstraint(leading)
        }
        
        if constrainTrailingToSuperviewTrailing {
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .trailing,
                multiplier: 1,
                constant: contentInsets.right * -1
            )
            
            contentView.addConstraint(trailing)
        }
    }
    
    private func addTopAndBottomConstraintsToChildView(childView: MobileContentView) {
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: childView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: contentView,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        if let lastAddedBottomConstraint = self.lastAddedBottomConstraint {
            contentView.removeConstraint(lastAddedBottomConstraint)
        }
        
        contentView.addConstraint(bottom)
        
        let top: NSLayoutConstraint
        
        if let lastView = lastAddedView {
            
            top = NSLayoutConstraint(
                item: childView,
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
                item: childView,
                attribute: .top,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .top,
                multiplier: 1,
                constant: contentInsets.top
            )
        }
        
        contentView.addConstraint(top)
        
        lastAddedView = childView
        lastAddedBottomConstraint = bottom
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
