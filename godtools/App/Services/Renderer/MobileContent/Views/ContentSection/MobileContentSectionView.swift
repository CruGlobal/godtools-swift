//
//  MobileContentSectionView.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentSectionView: MobileContentView {
 
    private let viewModel: MobileContentSectionViewModelType
    
    private var headerView: MobileContentHeaderView?
    
    @IBOutlet weak private var headerContainerView: UIView!
    @IBOutlet weak private var textContainerView: UIView!
    
    required init(viewModel: MobileContentSectionViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
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
        
        layer.cornerRadius = 12
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3
        clipsToBounds = false
        
        headerContainerView.drawBorder(color: .red)
        textContainerView.drawBorder(color: .green)
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
