//
//  LegacyLessonPageView.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

class LegacyLessonPageView: LegacyMobileContentPageView {
    
    private let viewModel: LessonPageViewModel
    private let safeArea: UIEdgeInsets
    
    private var contentView: LegacyMobileContentStackView?
        
    @IBOutlet weak private var topInset: UIView!
    @IBOutlet weak private var contentContainerView: UIView!
    @IBOutlet weak private var bottomInset: UIView!
    
    @IBOutlet weak private var topInsetTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var bottomInsetBottomConstraint: NSLayoutConstraint!
    
    init(viewModel: LessonPageViewModel, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.safeArea = safeArea
        
        super.init(viewModel: viewModel, nibName: String(describing: LegacyLessonPageView.self))
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
    
    // MARK: - LegacyMobileContentView

    override func renderChild(childView: LegacyMobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let contentView = childView as? LegacyMobileContentStackView {
            addContentView(contentView: contentView)
        }
    }
}

// MARK: - ContentView

extension LegacyLessonPageView {
    
    private func addContentView(contentView: LegacyMobileContentStackView) {
        
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
