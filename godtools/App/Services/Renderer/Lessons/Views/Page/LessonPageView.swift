//
//  LessonPageView.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonPageView: MobileContentPageView {
    
    private let viewModel: LessonPageViewModelType
    private let safeArea: UIEdgeInsets
    
    private var contentView: LessonContentView?
    
    @IBOutlet weak private var contentContainerView: UIView!
    
    required init(viewModel: LessonPageViewModelType, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.safeArea = safeArea
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: LessonPageView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.backgroundColor = .clear
            rootNibView.frame = bounds
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
    
    // MARK: - MobileContentView

    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let contentView = childView as? LessonContentView {
            addContentView(contentView: contentView)
        }
    }
}

// MARK: - ContentView

extension LessonPageView {
    
    private func addContentView(contentView: LessonContentView) {
        
        guard self.contentView == nil else {
            return
        }
        
        contentContainerView.isHidden = false
        contentContainerView.addSubview(contentView)
        contentView.constrainEdgesToSuperview()
        self.contentView = contentView
    }
}
