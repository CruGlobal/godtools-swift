//
//  MobileContentCardView.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardView: MobileContentStackView {
    
    private let viewModel: MobileContentCardViewModelType
    private let viewCornerRadius: CGFloat = 10
    
    private var shadowView: UIView?
    private var buttonOverlay: UIButton?
    
    required init(viewModel: MobileContentCardViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(contentInsets: UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15), itemSpacing: 0, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(contentInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    private func setupLayout() {
        
        backgroundColor = .white
        layer.cornerRadius = viewCornerRadius
        
        drawShadow()
    }
    
    private func setupBinding() {
        
    }
    
    override var paddingInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
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
        
        super.sendEventsToAllViews(eventIds: viewModel.events, rendererState: viewModel.rendererState)
    }
}
