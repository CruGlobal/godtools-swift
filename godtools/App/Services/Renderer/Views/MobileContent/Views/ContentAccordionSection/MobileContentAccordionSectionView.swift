//
//  MobileContentAccordionSectionView.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentAccordionSectionViewDelegate: AnyObject {
    
    func sectionViewDidChangeTextHiddenState(sectionView: MobileContentAccordionSectionView, textIsHidden: Bool, textHeight: CGFloat)
}

class MobileContentAccordionSectionView: MobileContentView {
 
    private let viewModel: MobileContentAccordionSectionViewModelType
    private let viewCornerRadius: CGFloat = 10
    
    private var headerView: MobileContentHeaderView?
    private var textView: MobileContentTextView?
    private(set) var textIsHidden: Bool = true
    
    private weak var delegate: MobileContentAccordionSectionViewDelegate?
    
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var textContainerView: UIView!
    @IBOutlet weak private var headerContainerView: UIView!
    @IBOutlet weak private var textStateImageView: UIImageView!
    @IBOutlet weak private var revealTextButton: UIButton!
    
    @IBOutlet private var headerContainerBottomToView: NSLayoutConstraint!
    @IBOutlet private var textContainerBottomToView: NSLayoutConstraint!
    @IBOutlet weak private var textStateImageTrailing: NSLayoutConstraint!
    
    required init(viewModel: MobileContentAccordionSectionViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        
        revealTextButton.addTarget(self, action: #selector(revealTextButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: MobileContentAccordionSectionView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToSuperview()
            rootNibView.backgroundColor = .clear
            backgroundColor = .clear
        }
    }
    
    private func setupLayout() {
        
        // shadowView
        shadowView.layer.cornerRadius = viewCornerRadius
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.3
        
        // contentView
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = viewCornerRadius
        contentView.clipsToBounds = true
        
        // textContainerView
        textContainerView.alpha = 0
                
        setTextHidden(hidden: true, animated: false)
    }
    
    @objc func revealTextButtonTapped() {
        
        setTextHidden(hidden: !textIsHidden, animated: true)
    }
    
    var viewHeight: CGFloat {
        return headerHeight + textHeight
    }
    
    var headerHeight: CGFloat {
        return headerContainerView.frame.size.height
    }
    
    var textHeight: CGFloat {
        if textIsHidden {
            return 0
        }
        return textContainerView.frame.size.height
    }
    
    func setDelegate(delegate: MobileContentAccordionSectionViewDelegate?) {
        self.delegate = delegate
    }
    
    func setTextHidden(hidden: Bool, animated: Bool) {
        
        textIsHidden = hidden
        
        let textAlpha: CGFloat
        let textHeight: CGFloat = textContainerView.frame.size.height
        let textStateImage: UIImage?
        
        if hidden {
            
            textAlpha = 0
            textContainerBottomToView.isActive = false
            headerContainerBottomToView.isActive = true
            textStateImage = ImageCatalog.accordionSectionPlus.image
        }
        else {
            
            textAlpha = 1
            headerContainerBottomToView.isActive = false
            textContainerBottomToView.isActive = true
            textStateImage = ImageCatalog.accordionSectionMinus.image
        }
        
        textStateImageView.image = textStateImage
                
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                guard let view = self else {
                    return
                }
                
                view.textContainerView.alpha = textAlpha
                view.delegate?.sectionViewDidChangeTextHiddenState(sectionView: view, textIsHidden: hidden, textHeight: textHeight)
            }, completion: nil)
        }
        else {
            
            textContainerView.alpha = textAlpha
            delegate?.sectionViewDidChangeTextHiddenState(sectionView: self, textIsHidden: hidden, textHeight: textHeight)
        }
    }
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let headerView = childView as? MobileContentHeaderView {
            addHeaderView(headerView: headerView)
        }
        else if let textView = childView as? MobileContentTextView {
            addTextView(textView: textView)
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
        
        headerContainerView.addSubview(headerView)
        headerView.constrainEdgesToSuperview(edgeInsets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: textStateImageTrailing.constant + textStateImageView.frame.size.width + 10))
        self.headerView = headerView
    }
}

// MARK: - Text

extension MobileContentAccordionSectionView {
    
    private func addTextView(textView: MobileContentTextView) {
        
        guard self.textView == nil else {
            return
        }
        
        textContainerView.addSubview(textView)
        textView.constrainEdgesToSuperview(edgeInsets: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
        self.textView = textView
    }
}
