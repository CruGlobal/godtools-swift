//
//  MobileContentAccordionView.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentAccordionViewDelegate: AnyObject {
    
    func accordionViewDidChangeSectionViewContentHiddenState(accordionView: MobileContentAccordionView, sectionView: MobileContentAccordionSectionView, contentIsHidden: Bool, contentHeight: CGFloat)
}

class MobileContentAccordionView: MobileContentView {
    
    private let viewModel: MobileContentAccordionViewModelType
    private let allowsOnlyOneExpandedSectionAtATime: Bool = true
    
    private var sectionViews: [MobileContentAccordionSectionView] = Array()
    private var spacingBetweenSections: CGFloat = 15
    private var sectionViewsAdded: Bool = false
    
    private weak var delegate: MobileContentAccordionViewDelegate?
        
    required init(viewModel: MobileContentAccordionViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    var isRevealingSectionText: Bool {
        for sectionView in sectionViews {
            if !sectionView.contentIsHidden {
                return true
            }
        }
        return false
    }
    
    func setDelegate(delegate: MobileContentAccordionViewDelegate?) {
        self.delegate = delegate
    }
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let sectionView = childView as? MobileContentAccordionSectionView {
            sectionViews.append(sectionView)
            sectionView.setDelegate(delegate: self)
        }
    }
    
    override func finishedRenderingChildren() {
        
        super.finishedRenderingChildren()
        
        addSectionViews(sectionViews: sectionViews)
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}

extension MobileContentAccordionView {
    
    private func addSectionViews(sectionViews: [MobileContentAccordionSectionView]) {
        
        guard !sectionViewsAdded else {
            return
        }
        sectionViewsAdded = true
        
        let parentView: UIView = self
        let numberOfSections: Int = sectionViews.count
        let lastSectionIndex: Int = numberOfSections - 1
        
        var previousSectionView: MobileContentView?
        
        for index in stride(from: lastSectionIndex, through: 0, by: -1) {
            
            let sectionView: MobileContentAccordionSectionView = sectionViews[index]
            
            sectionView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(sectionView)
            
            let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
                item: sectionView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: 10
            )
            
            heightConstraint.priority = UILayoutPriority(500)
            
            sectionView.addConstraint(heightConstraint)
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: sectionView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            )
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: sectionView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: parentView,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            )
            
            let bottom: NSLayoutConstraint
            
            if index == lastSectionIndex {
                
                bottom = NSLayoutConstraint(
                    item: sectionView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: parentView,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: 0
                )
            }
            else if let previousSectionView = previousSectionView {
                
                bottom = NSLayoutConstraint(
                    item: sectionView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: previousSectionView,
                    attribute: .top,
                    multiplier: 1,
                    constant: spacingBetweenSections * -1
                )
            }
            else {
                
                bottom = NSLayoutConstraint(
                    item: sectionView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: parentView,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: 0
                )
            }
            
            parentView.addConstraint(leading)
            parentView.addConstraint(trailing)
            parentView.addConstraint(bottom)
            
            if index == 0 {
                
                let top: NSLayoutConstraint = NSLayoutConstraint(
                    item: sectionView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: parentView,
                    attribute: .top,
                    multiplier: 1,
                    constant: 0
                )
                
                parentView.addConstraint(top)
            }
            
            previousSectionView = sectionView
        }
    }
}

// MARK: - MobileContentSectionViewDelegate

extension MobileContentAccordionView: MobileContentAccordionSectionViewDelegate {
    
    func sectionViewDidChangeContentHiddenState(sectionView: MobileContentAccordionSectionView, contentIsHidden: Bool, contentHeight: CGFloat) {
        
        if allowsOnlyOneExpandedSectionAtATime && !contentIsHidden {
            for otherSectionView in sectionViews {
                if otherSectionView != sectionView && !otherSectionView.contentIsHidden {
                    otherSectionView.setContentHidden(hidden: true, animated: true)
                }
            }
        }
        
        delegate?.accordionViewDidChangeSectionViewContentHiddenState(
            accordionView: self,
            sectionView: sectionView,
            contentIsHidden: contentIsHidden,
            contentHeight: contentHeight
        )
    }
}
