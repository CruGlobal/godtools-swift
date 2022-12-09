//
//  LessonPageView.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class LessonPageView: MobileContentPageView {
    
    private let viewModel: LessonPageViewModel
    private let safeArea: UIEdgeInsets
    
    private var contentView: MobileContentStackView?
        
    @IBOutlet weak private var topInset: UIView!
    @IBOutlet weak private var contentContainerView: UIView!
    @IBOutlet weak private var bottomInset: UIView!
    
    @IBOutlet weak private var topInsetTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var bottomInsetBottomConstraint: NSLayoutConstraint!
    
    required init(viewModel: LessonPageViewModel, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.safeArea = safeArea
        
        super.init(viewModel: viewModel, nibName: String(describing: LessonPageView.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        topInsetTopConstraint.constant = safeArea.top
        bottomInsetBottomConstraint.constant = safeArea.bottom
        
        // topInset
        topInset.backgroundColor = .clear
        topInset.isUserInteractionEnabled = false
        
        // bottomInset
        bottomInset.backgroundColor = .clear
        bottomInset.isUserInteractionEnabled = false
        
        // contentContainerView
        contentContainerView.backgroundColor = .clear
    }
    
    override func setupBinding() {
        super.setupBinding()
        
    }
    
    // MARK: - MobileContentView

    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let contentView = childView as? MobileContentStackView {
            addContentView(contentView: contentView)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        viewModel.pageDidAppear()
    }
}

// MARK: - ContentView

extension LessonPageView {
    
    private func addContentView(contentView: MobileContentStackView) {
        
        guard self.contentView == nil else {
            return
        }
        
        contentContainerView.isHidden = false
        
        contentContainerView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.constrainEdgesToView(view: contentContainerView)
        
        self.contentView = contentView        
    }
}
