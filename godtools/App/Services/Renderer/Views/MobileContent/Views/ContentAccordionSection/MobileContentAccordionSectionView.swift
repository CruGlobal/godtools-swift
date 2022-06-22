//
//  MobileContentAccordionSectionView.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol MobileContentAccordionSectionViewDelegate: AnyObject {
    
    func sectionViewDidChangeContentHiddenState(sectionView: MobileContentAccordionSectionView, contentIsHidden: Bool, contentHeight: CGFloat)
}

class MobileContentAccordionSectionView: MobileContentView, NibBased {
 
    private let viewModel: MobileContentAccordionSectionViewModelType
    private let contentStack: MobileContentStackView
    private let viewCornerRadius: CGFloat = 10
    
    private var headerView: MobileContentHeaderView?
    private(set) var contentIsHidden: Bool = true
    
    private weak var delegate: MobileContentAccordionSectionViewDelegate?
    
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var headerContainerView: UIView!
    @IBOutlet weak private var headerButton: UIButton!
    @IBOutlet weak private var accordionStateImageView: UIImageView!
    
    @IBOutlet private var headerContainerBottomToView: NSLayoutConstraint!
    @IBOutlet private var contentStackContainerBottomToView: NSLayoutConstraint!
    @IBOutlet weak private var textStateImageTrailing: NSLayoutConstraint!
    
    required init(viewModel: MobileContentAccordionSectionViewModelType) {
        
        self.viewModel = viewModel
        
        self.contentStack = MobileContentStackView(
            contentInsets: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20),
            itemSpacing: 10,
            scrollIsEnabled: false
        )
        
        super.init(frame: UIScreen.main.bounds)
        
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
    
    func setDelegate(delegate: MobileContentAccordionSectionViewDelegate?) {
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
            accordionStateImage = ImageCatalog.accordionSectionPlus.image
        }
        else {
            
            contentAlpha = 1
            headerContainerBottomToView.isActive = false
            contentStackContainerBottomToView.isActive = true
            accordionStateImage = ImageCatalog.accordionSectionMinus.image
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
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let headerView = childView as? MobileContentHeaderView, self.headerView == nil {
            addHeaderView(headerView: headerView)
        }
        else {
            contentStack.renderChild(childView: childView)
        }
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}

// MARK: - Header Text

extension MobileContentAccordionSectionView {
    
    private func addHeaderView(headerView: MobileContentHeaderView) {
        
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
