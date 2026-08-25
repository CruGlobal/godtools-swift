//
//  LegacyMobileContentAccordionSectionView.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

@MainActor
protocol LegacyMobileContentAccordionSectionViewDelegate: AnyObject {
    
    func sectionViewDidChangeContentHiddenState(sectionView: LegacyMobileContentAccordionSectionView, contentIsHidden: Bool, contentHeight: CGFloat)
}

class LegacyMobileContentAccordionSectionView: LegacyMobileContentView, NibBased {
 
    private let viewModel: LegacyMobileContentAccordionSectionViewModel
    private let contentStack: LegacyMobileContentStackView
    private let viewCornerRadius: CGFloat = 10
    
    private var headerView: LegacyMobileContentHeaderView?
    private(set) var contentIsHidden: Bool = true
    
    private weak var delegate: LegacyMobileContentAccordionSectionViewDelegate?
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var headerContainerView: UIView!
    @IBOutlet weak private var headerButton: UIButton!
    @IBOutlet weak private var accordionStateImageView: UIImageView!
    
    @IBOutlet private var headerContainerBottomToView: NSLayoutConstraint!
    @IBOutlet private var contentStackContainerBottomToView: NSLayoutConstraint!
    @IBOutlet weak private var textStateImageTrailing: NSLayoutConstraint!
    
    init(viewModel: LegacyMobileContentAccordionSectionViewModel) {
        
        self.viewModel = viewModel
        
        self.contentStack = LegacyMobileContentStackView(
            viewModel: viewModel,
            contentInsets: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20),
            scrollIsEnabled: false
        )
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        loadNib()
        setupLayout()
        
        headerButton.addTarget(self, action: #selector(headerTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        layer.cornerRadius = viewCornerRadius
        
        drawShadow()
        
        // contentView
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = viewCornerRadius
        contentView.clipsToBounds = true
        
        // contentStackContainerView
        contentStackContainerView.alpha = 0
        contentStackContainerView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.constrainEdgesToView(view: contentStackContainerView)
        super.renderChild(childView: contentStack)
        
        // headerButton
        headerButton.setTitle("", for: .normal)
          
        setContentHidden(hidden: true, animated: false)
    }
    
    @objc private func headerTapped() {
        toggleContentHidden()
    }
    
    private func toggleContentHidden() {
        setContentHidden(hidden: !contentIsHidden, animated: true)
    }
    
    var viewHeight: CGFloat {
        return headerHeight + contentHeight
    }
    
    private var headerHeight: CGFloat {
        return headerContainerView.frame.size.height
    }
    
    private var contentHeight: CGFloat {
        
        return contentStackContainerView.frame.size.height
    }
    
    func setDelegate(delegate: LegacyMobileContentAccordionSectionViewDelegate?) {
        self.delegate = delegate
    }
    
    func setContentHidden(hidden: Bool, animated: Bool) {
        
        contentIsHidden = hidden
        
        let contentAlpha: CGFloat
        let accordionStateImage: UIImage?
        
        if hidden {
            
            contentAlpha = 0
            contentStackContainerBottomToView.isActive = false
            headerContainerBottomToView.isActive = true
            accordionStateImage = ImageCatalog.accordionSectionPlus.uiImage
            viewModel.sectionClosed()
        }
        else {
            
            contentAlpha = 1
            headerContainerBottomToView.isActive = false
            contentStackContainerBottomToView.isActive = true
            accordionStateImage = ImageCatalog.accordionSectionMinus.uiImage
            viewModel.sectionOpened()
        }
        
        accordionStateImageView.image = accordionStateImage
                
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.contentStackContainerView.alpha = contentAlpha
                self.delegate?.sectionViewDidChangeContentHiddenState(sectionView: self, contentIsHidden: hidden, contentHeight: self.contentHeight)
            }, completion: nil)
        }
        else {
            
            contentStackContainerView.alpha = contentAlpha
            delegate?.sectionViewDidChangeContentHiddenState(sectionView: self, contentIsHidden: hidden, contentHeight: contentHeight)
        }
    }
    
    override func renderChild(childView: LegacyMobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let headerView = childView as? LegacyMobileContentHeaderView, self.headerView == nil {
            addHeaderView(headerView: headerView)
        }
        else {
            contentStack.renderChild(childView: childView)
        }
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    override func getPositionState() -> MobileContentViewPositionState {
        
        return MobileContentAccordionSectionPositionState(contentIsHidden: contentIsHidden)
    }
    
    override func setPositionState(positionState: MobileContentViewPositionState, animated: Bool) {
        
        guard let positionState = positionState as? MobileContentAccordionSectionPositionState else {
            return
        }
        
        setContentHidden(hidden: positionState.contentIsHidden, animated: false)
    }
}

// MARK: - Header Text

extension LegacyMobileContentAccordionSectionView {
    
    private func addHeaderView(headerView: LegacyMobileContentHeaderView) {
        
        guard self.headerView == nil else {
            return
        }
        
        let parentView: UIView = headerContainerView
        parentView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.constrainEdgesToView(view: parentView, edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: textStateImageTrailing.constant + accordionStateImageView.frame.size.width + 10))
        self.headerView = headerView
    }
}
