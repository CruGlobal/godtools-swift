//
//  MobileContentStackView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentStackView: MobileContentView {
        
    private let boundsKeyPath: String = #keyPath(UIView.bounds)
    private let minimumContentInsetToPreventShadowClippingOnScrollableContent: CGFloat = 10
    
    private var scrollView: UIScrollView?
    private var childrenParentView: UIView = UIView()
    private var childViews: [MobileContentView] = Array()
    private var lastAddedChildView: MobileContentView?
    private var lastAddedChildBottomConstraint: NSLayoutConstraint?
    private var autoSpacerViews: [MobileContentSpacerView] = Array()
    private var contentInsetsForScrollableContent: UIEdgeInsets = .zero
    private var contentInsetsForNonScrollableContent: UIEdgeInsets = .zero
    private var itemSpacing: CGFloat = 0
    private var scrollIsEnabled: Bool = true
    private var isObservingBoundsChanges: Bool = false
    private var lastRenderedParentBounds: CGRect?
            
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
                
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: itemSpacing))
        
        configureLayout(contentInsets: contentInsets, itemSpacing: itemSpacing, scrollIsEnabled: scrollIsEnabled)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeBoundsChangeObserverOnChildrenParentView()
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
    }
    
    override func removeAllChildren() {
        
        childViews.removeAll()
        autoSpacerViews.removeAll()
        lastAddedChildView = nil
        lastAddedChildBottomConstraint = nil
        
        super.removeAllChildren()
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
    
    private var contentInsets: UIEdgeInsets {
        
        get {
            
            return scrollIsEnabled ? contentInsetsForScrollableContent : contentInsetsForNonScrollableContent
        }
        set (newValue) {
            
            let minimumContentInsetsToScrollViewToPreventShadowClipping = UIEdgeInsets(
                top: max(newValue.top, minimumContentInsetToPreventShadowClippingOnScrollableContent),
                left: max(newValue.left, minimumContentInsetToPreventShadowClippingOnScrollableContent),
                bottom: max(newValue.bottom, minimumContentInsetToPreventShadowClippingOnScrollableContent),
                right: max(newValue.right, minimumContentInsetToPreventShadowClippingOnScrollableContent)
            )
            
            self.contentInsetsForScrollableContent = minimumContentInsetsToScrollViewToPreventShadowClipping
            
            self.contentInsetsForNonScrollableContent = newValue
        }
    }
    
    var isEmpty: Bool {
        return childrenParentView.subviews.isEmpty
    }
    
    var scrollViewFrame: CGRect? {
        return scrollView?.frame
    }
    
    var contentSize: CGSize {
        return scrollView?.contentSize ?? childrenParentView.frame.size
    }
    
    func setScrollViewContentSize(size: CGSize) {
        scrollView?.contentSize = size
    }
    
    func getScrollViewContentInset() -> UIEdgeInsets? {
        return scrollView?.contentInset
    }
    
    func setScrollViewContentInset(contentInset: UIEdgeInsets) {
        if let scrollView = self.scrollView {
            scrollView.contentInset = contentInset
            relayoutForSpacerViews()
        }
    }
    
    func getScrollViewVerticalContentOffsetPercentageOfContentSize() -> CGFloat {
       
        guard let scrollView = self.scrollView else {
            return 0
        }
        
        let contentSize: CGSize = scrollView.contentSize
        let contentOffset: CGPoint = scrollView.contentOffset
        
        guard contentSize.height > 0 else {
            return 0
        }
        
        let verticalContentOffset: CGFloat = contentOffset.y / contentSize.height
        
        return verticalContentOffset
    }
    
    func setScrollViewVerticalContentOffsetPercentageOfContentSize(verticalContentOffsetPercentage: CGFloat, animated: Bool) {
        
        guard let scrollView = self.scrollView else {
            return
        }
        
        let contentSize: CGSize = scrollView.contentSize
        let contentOffsetY: CGFloat = verticalContentOffsetPercentage * contentSize.height
        
        setScrollViewContentOffset(contentOffset: CGPoint(x: scrollView.contentOffset.x, y: contentOffsetY), animated: animated)
    }
    
    func getScrollViewContentOffset() -> CGPoint? {
        return scrollView?.contentOffset
    }
    
    func setScrollViewContentOffset(contentOffset: CGPoint, animated: Bool) {
        scrollView?.setContentOffset(contentOffset, animated: animated)
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
        
        guard spacerView.height.isAuto else {
            assertionFailure("Only spacer's with mode auto can be added.")
            return
        }

        spacerView.setHeight(height: 0)
        autoSpacerViews.append(spacerView)
    }
}

// MARK: - Bounds Change Observing

extension MobileContentStackView {
    
    private func renderForBoundsChangeIfNeeded() {
             
        let currentBounds: CGRect = childrenParentView.frame
        
        guard currentBounds.width > 0 && currentBounds.height > 0 else {
            return
        }
        
        let boundsChanged: Bool
        
        if let lastRenderedParentBounds = lastRenderedParentBounds {
            boundsChanged = !currentBounds.equalTo(lastRenderedParentBounds)
        }
        else {
            boundsChanged = true
        }
        
        guard boundsChanged else{
            return
        }
        
        var needsLayoutUpdate: Bool = false
        
        for childView in childViews {
                        
            switch childView.heightConstraintType {
            
            case .lessThanOrEqualToWidthPercentageSizeOfContainer(let widthPercentageSizeOfContainer, let maintainsAspectRatioSize):
                
                needsLayoutUpdate = true
                
                addWidthAndHeightConstraintsToChildViewWithMaxWidthSizePercentageOfContainer(
                    childView: childView,
                    widthPercentageSizeOfContainer: widthPercentageSizeOfContainer,
                    maintainsAspectRatioSize: maintainsAspectRatioSize
                )
            
            case .lessThanOrEqualToWidthPointSize(let widthPointSize, let maintainsAspectRatioSize):
                
                needsLayoutUpdate = true
                
                addWidthAndHeightConstraintsToChildViewWithMaxWidthSize(
                    childView: childView,
                    maxWidthSize: widthPointSize,
                    maintainsAspectRatioSize: maintainsAspectRatioSize
                )
            
            default:
                continue
            }
        }
                        
        lastRenderedParentBounds = currentBounds
        
        if needsLayoutUpdate {
            childrenParentView.layoutIfNeeded()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            
        guard let objectValue = object as? NSObject else {
            return
        }
        
        if objectValue == childrenParentView && keyPath == boundsKeyPath {
            renderForBoundsChangeIfNeeded()
        }
    }
    
    private func removeBoundsChangeObserverOnChildrenParentView() {
        
        guard isObservingBoundsChanges else {
            return
        }
        
        isObservingBoundsChanges = false
        
        childrenParentView.removeObserver(self, forKeyPath: boundsKeyPath, context: nil)
    }
    
    private func addBoundsChangeObserverOnChildrenParentView() {
        
        guard !isObservingBoundsChanges else {
            return
        }
        
        isObservingBoundsChanges = true
        
        childrenParentView.addObserver(self, forKeyPath: boundsKeyPath, options: [.new], context: nil)
    }
}

// MARK: - Build Layout

extension MobileContentStackView {
    
    func configureLayout(contentInsets: UIEdgeInsets?, itemSpacing: CGFloat?, scrollIsEnabled: Bool?) {
        
        removeBoundsChangeObserverOnChildrenParentView()

        scrollView?.removeFromSuperview()
        childrenParentView.removeFromSuperview()
        autoSpacerViews.removeAll()
        lastAddedChildView = nil
        lastAddedChildBottomConstraint = nil
        scrollView = nil
        lastRenderedParentBounds = nil
        
        //
        if let contentInsets = contentInsets {
            self.contentInsets = contentInsets
        }
        
        if let itemSpacing = itemSpacing {
            self.itemSpacing = itemSpacing
        }
        
        if let scrollIsEnabled = scrollIsEnabled {
            self.scrollIsEnabled = scrollIsEnabled
        }
        
        // add scrollview and content view
        translatesAutoresizingMaskIntoConstraints = false
        
        let contentViewParent: UIView
        
        if self.scrollIsEnabled {
            
            let newScrollView: UIScrollView = UIScrollView()
            addSubview(newScrollView)
            newScrollView.translatesAutoresizingMaskIntoConstraints = false
            newScrollView.constrainEdgesToView(view: self)
            
            contentViewParent = newScrollView
            
            self.scrollView = newScrollView
        }
        else {
            
            contentViewParent = self
        }
        
        childrenParentView = UIView()
        contentViewParent.addSubview(childrenParentView)
        childrenParentView.translatesAutoresizingMaskIntoConstraints = false
        childrenParentView.constrainEdgesToView(view: contentViewParent)
        childrenParentView.backgroundColor = .clear
        
        if let scrollView = self.scrollView {
            
            scrollView.backgroundColor = .clear
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            
            let equalWidths: NSLayoutConstraint = NSLayoutConstraint(
                item: scrollView,
                attribute: .width,
                relatedBy: .equal,
                toItem: childrenParentView,
                attribute: .width,
                multiplier: 1,
                constant: 0
            )
            
            scrollView.addConstraint(equalWidths)
        }
        
        addBoundsChangeObserverOnChildrenParentView()
        
        // build layout if needed
        guard childViews.count > 0 else {
            return
        }
        
        let currentChildViews: [MobileContentView] = childViews
        childViews = Array()
        
        for childView in currentChildViews {
            addChildView(childView: childView)
        }
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
                      
        childrenParentView.addSubview(childContentView)
        
        childViews.append(childView)
                
        childContentView.translatesAutoresizingMaskIntoConstraints = false
           
        addLeadingTrailingAndHeightConstraintsToChildView(childView: childView)
        
        addTopAndBottomConstraintsToChildView(childView: childView)
        
        relayoutForSpacerViews()
        
        if let accordionView = childView as? MobileContentAccordionView {
            accordionView.setDelegate(delegate: self)
        }
    }
    
    private func relayoutTopAndBottomConstraintsForChildViews() {
        
        lastAddedChildView = nil
        lastAddedChildBottomConstraint = nil
        
        let contentViewConstraints: [NSLayoutConstraint] = childrenParentView.constraints
        
        for index in stride(from: contentViewConstraints.count - 1, through: 0, by: -1) {
            
            let constraint: NSLayoutConstraint = contentViewConstraints[index]
            
            if constraint.firstAttribute == .top || constraint.firstAttribute == .bottom {
                childrenParentView.removeConstraint(constraint)
            }
        }
        
        for childView in childViews {
            if childView.visibilityState == .visible {
                addTopAndBottomConstraintsToChildView(childView: childView)
            }
        }
        
        childrenParentView.layoutIfNeeded()
        
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
            
        case .lessThanOrEqualToWidthPercentageSizeOfContainer(let widthPercentageSizeOfContainer, let maintainsAspectRatioSize):
            
            constrainLeadingToSuperviewLeading = false
            constrainTrailingToSuperviewTrailing = false
            
            addWidthAndHeightConstraintsToChildViewWithMaxWidthSizePercentageOfContainer(
                childView: childView,
                widthPercentageSizeOfContainer: widthPercentageSizeOfContainer,
                maintainsAspectRatioSize: maintainsAspectRatioSize
            )
            
            childView.constrainCenterHorizontallyInView(view: childrenParentView)
            
        case .lessThanOrEqualToWidthPointSize(let widthPointSize, let maintainsAspectRatioSize):
            
            constrainLeadingToSuperviewLeading = false
            constrainTrailingToSuperviewTrailing = false
            
            addWidthAndHeightConstraintsToChildViewWithMaxWidthSize(
                childView: childView,
                maxWidthSize: widthPointSize,
                maintainsAspectRatioSize: maintainsAspectRatioSize
            )
            
            childView.constrainCenterHorizontallyInView(view: childrenParentView)
            
        case .setToAspectRatioOfProvidedSize(let size):
                   
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            let multiplier: CGFloat
            if size.width != 0 {
                multiplier = size.height / size.width
            } else {
                multiplier = 1
            }
            
            let aspectRatio: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .height,
                relatedBy: .equal,
                toItem: childView,
                attribute: .width,
                multiplier: multiplier,
                constant: 0
            )
            
            childView.addConstraint(aspectRatio)
            
        case .spacer:
           
            constrainLeadingToSuperviewLeading = true
            constrainTrailingToSuperviewTrailing = true
            
            if let spacerView = childView as? MobileContentSpacerView {
                                
                if spacerView.height.isAuto {
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
                toItem: childrenParentView,
                attribute: .leading,
                multiplier: 1,
                constant: contentInsets.left + childView.paddingInsets.left
            )
            
            childrenParentView.addConstraint(leading)
        }
        
        if constrainTrailingToSuperviewTrailing {
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: childView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: childrenParentView,
                attribute: .trailing,
                multiplier: 1,
                constant: (contentInsets.right * -1) + (childView.paddingInsets.right * -1)
            )
            
            childrenParentView.addConstraint(trailing)
        }
    }
    
    private func addTopAndBottomConstraintsToChildView(childView: MobileContentView) {
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: childView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: childrenParentView,
            attribute: .bottom,
            multiplier: 1,
            constant: (contentInsets.bottom * -1) + (childView.paddingInsets.bottom * -1)
        )
        
        if let lastAddedChildBottomConstraint = self.lastAddedChildBottomConstraint {
            childrenParentView.removeConstraint(lastAddedChildBottomConstraint)
        }
        
        childrenParentView.addConstraint(bottom)
        
        let top: NSLayoutConstraint
        
        if let lastView = lastAddedChildView {
            
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
                toItem: childrenParentView,
                attribute: .top,
                multiplier: 1,
                constant: contentInsets.top + childView.paddingInsets.top
            )
        }
        
        childrenParentView.addConstraint(top)
        
        lastAddedChildView = childView
        lastAddedChildBottomConstraint = bottom
    }
    
    private func addWidthAndHeightConstraintsToChildViewWithMaxWidthSizePercentageOfContainer(childView: MobileContentView, widthPercentageSizeOfContainer: CGFloat, maintainsAspectRatioSize: CGSize?) {
        
        let parentWidth: CGFloat = childrenParentView.frame.size.width
        let widthSize: CGFloat
        
        if parentWidth > 0 {
            widthSize = parentWidth * widthPercentageSizeOfContainer
        }
        else {
            
            widthSize = 60
        }
        
        addWidthAndHeightConstraintsToChildViewWithMaxWidthSize(childView: childView, maxWidthSize: widthSize, maintainsAspectRatioSize: maintainsAspectRatioSize)
    }
    
    private func addWidthAndHeightConstraintsToChildViewWithMaxWidthSize(childView: MobileContentView, maxWidthSize: CGFloat, maintainsAspectRatioSize: CGSize?) {
        
        let size: CGSize = calculateSizeFromWidth(width: maxWidthSize, maintainsAspectRatioSize: maintainsAspectRatioSize)
        let clampedSize: CGSize = clampSizeToChildrenParentSizeAndInsets(size: size)
        
        var widthConstraint: NSLayoutConstraint?
        var heightConstraint: NSLayoutConstraint?
        
        for constraint in childView.constraints {
            
            if constraint.firstAttribute == .width {
                widthConstraint = constraint
            }
            else if constraint.firstAttribute == .height {
                heightConstraint = constraint
            }
            
            if widthConstraint != nil && heightConstraint != nil {
                break
            }
        }
        
        if let widthConstraint = widthConstraint {
            widthConstraint.constant = clampedSize.width
        }
        else {
            _ = childView.addWidthConstraint(constant: clampedSize.width, priority: 1000)
        }
        
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = clampedSize.height
        }
        else {
            _ = childView.addHeightConstraint(constant: clampedSize.height, priority: 1000)
        }
    }
    
    private func calculateSizeFromWidth(width: CGFloat, maintainsAspectRatioSize: CGSize?) -> CGSize {
        
        guard let aspectRatioSize = maintainsAspectRatioSize else {
            return CGSize(width: width, height: width)
        }
        
        let height: CGFloat
        
        if aspectRatioSize.width > 0 && aspectRatioSize.height > 0 {
            
            height = (width / aspectRatioSize.width) * aspectRatioSize.height
        }
        else {
            
            height = width
        }
        
        return CGSize(width: width, height: height)
    }
    
    private func clampSizeToChildrenParentSizeAndInsets(size: CGSize) -> CGSize {
        
        let parentWidth: CGFloat = childrenParentView.frame.size.width
        let parentWidthMinusContentInsets: CGFloat = parentWidth - (contentInsets.left + contentInsets.right)
        
        let pointsToTrim: CGFloat
        
        if size.width > parentWidthMinusContentInsets && parentWidthMinusContentInsets > 0 {
            pointsToTrim = size.width - parentWidthMinusContentInsets
        }
        else if size.width > parentWidth && parentWidth > 0 {
            pointsToTrim = size.width - parentWidth
        }
        else {
            pointsToTrim = 0
        }
        
        let clampedSize: CGSize = CGSize(
            width: floor(size.width - pointsToTrim),
            height: floor(size.height - pointsToTrim)
        )
                
        return clampedSize
    }
}

// MARK: - MobileContentAccordionViewDelegate

extension MobileContentStackView: MobileContentAccordionViewDelegate {
    
    func accordionViewDidChangeSectionViewContentHiddenState(accordionView: MobileContentAccordionView, sectionView: MobileContentAccordionSectionView, contentIsHidden: Bool, contentHeight: CGFloat) {
        
        layoutIfNeeded()
        
        relayoutForSpacerViews()
        
        guard let scrollView = self.scrollView, !contentIsHidden else {
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
