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
    
    private var shadowView: UIView?
    private var buttonOverlay: UIButton?
    
    required init(viewModel: MobileContentCardViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(contentInsets: .zero, itemSpacing: 0, scrollIsEnabled: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(contentInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    override func finishedRenderingChildren() {
        super.finishedRenderingChildren()
        
        drawShadow()
        addButtonOverlay()
    }
    
    private func drawShadow() {
        
        if let shadowView = self.shadowView {
            shadowView.removeFromSuperview()
            self.shadowView = nil
        }
        
        let shadowView: UIView = UIView()
        
        insertSubview(shadowView, at: 0)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.constrainEdgesToView(view: self)
        shadowView.backgroundColor = .white
        shadowView.layer.cornerRadius = 10
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.3
        
        self.shadowView = shadowView
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
