//
//  MobileContentCardView.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardView: MobileContentStackView {
    
    private let viewModel: MobileContentCardViewModel
    private let viewCornerRadius: CGFloat = 10
    
    private var shadowView: UIView?
    private var buttonOverlay: UIButton?
    
    init(viewModel: MobileContentCardViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10), itemSpacing: 0, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var paddingInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    private func setupLayout() {
        
        backgroundColor = .white
        layer.cornerRadius = viewCornerRadius
        
        drawShadow()
    }
    
    private func setupBinding() {
        
    }
    
    override func finishedRenderingChildren() {
        super.finishedRenderingChildren()
        
        addButtonOverlay()
    }
    
    private func addButtonOverlay() {
        
        if let buttonOverlay = self.buttonOverlay {
            buttonOverlay.removeTarget(self, action: #selector(cardTapped), for: .touchUpInside)
            buttonOverlay.removeFromSuperview()
            self.buttonOverlay = nil
        }
        
        let button = UIButton(type: .custom)
        
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.constrainEdgesToView(view: self)
        
        button.backgroundColor = .clear
        button.setTitle(nil, for: .normal)
        
        button.addTarget(self, action: #selector(cardTapped), for: .touchUpInside)
        
        self.buttonOverlay = button
    }
    
    @objc private func cardTapped() {
        
        viewModel.cardTapped()
        
        super.sendEventsToAllViews(eventIds: viewModel.events, rendererState: viewModel.rendererState)
        
        if let clickableUrl = viewModel.getClickableUrl() {
            super.sendButtonWithUrlEventToRootView(url: clickableUrl)
        }
    }
}
