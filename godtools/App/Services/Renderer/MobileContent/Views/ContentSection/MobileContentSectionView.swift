//
//  MobileContentSectionView.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentSectionViewDelegate: class {
    
    func contentSectionViewHeightDidChange(sectionView: MobileContentSectionView, heightAmountChanged: CGFloat)
}

class MobileContentSectionView: MobileContentView {
 
    private let viewModel: MobileContentSectionViewModelType
    
    private var headerView: MobileContentHeaderView?
    private var textIsHidden: Bool = true
    
    private weak var delegate: MobileContentSectionViewDelegate?
    
    @IBOutlet weak private var headerContainerView: UIView!
    @IBOutlet weak private var revealTextButton: UIButton!
    @IBOutlet weak private var textContainerView: UIView!
    
    @IBOutlet private var headerContainerBottomToView: NSLayoutConstraint!
    @IBOutlet private var textContainerBottomToView: NSLayoutConstraint!
    
    required init(viewModel: MobileContentSectionViewModelType) {
        
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
        
        let nib: UINib = UINib(nibName: String(describing: MobileContentSectionView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    private func setupLayout() {
        
        
        // layer shadow
        layer.cornerRadius = 12
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3
        clipsToBounds = false
        
        // textContainerView
        textContainerView.alpha = 0
        
        headerContainerView.drawBorder(color: .red)
        textContainerView.drawBorder(color: .green)
        textContainerView.backgroundColor = .magenta
        
        setTextHidden(hidden: true, animated: false)
    }
    
    @objc func revealTextButtonTapped() {
        
        setTextHidden(hidden: !textIsHidden, animated: true)
    }
    
    func setDelegate(delegate: MobileContentSectionViewDelegate?) {
        self.delegate = delegate
    }
    
    private func setTextHidden(hidden: Bool, animated: Bool) {
        
        textIsHidden = hidden
        
        let textAlpha: CGFloat
        let heightAmountChanged: CGFloat
        
        if hidden {
            
            textAlpha = 0
            textContainerBottomToView.isActive = false
            headerContainerBottomToView.isActive = true
            heightAmountChanged = 0
        }
        else {
            
            textAlpha = 1
            headerContainerBottomToView.isActive = false
            textContainerBottomToView.isActive = true
            heightAmountChanged = textContainerView.frame.size.height
        }
                
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                guard let view = self else {
                    return
                }
                
                view.textContainerView.alpha = textAlpha
                view.delegate?.contentSectionViewHeightDidChange(sectionView: view, heightAmountChanged: heightAmountChanged)
            }, completion: nil)
        }
        else {
            
            textContainerView.alpha = textAlpha
            delegate?.contentSectionViewHeightDidChange(sectionView: self, heightAmountChanged: heightAmountChanged)
        }
    }
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let headerView = childView as? MobileContentHeaderView {
            addHeaderView(headerView: headerView)
        }
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}

extension MobileContentSectionView {
    
    private func addHeaderView(headerView: MobileContentHeaderView) {
        
        guard self.headerView == nil else {
            return
        }
        
        headerContainerView.addSubview(headerView)
        headerView.constrainEdgesToSuperview()
        self.headerView = headerView
    }
}
