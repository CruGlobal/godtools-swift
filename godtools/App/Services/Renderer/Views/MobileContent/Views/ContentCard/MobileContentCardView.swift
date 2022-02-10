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
    
    private var button: UIButton?
    
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
        
        addButton()
    }
    
    private func addButton() {
        
        guard button == nil else {
            return
        }
        
        let button = UIButton(type: .custom)
        
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.constrainEdgesToView(view: self)
        
        button.backgroundColor = .clear
        button.setTitle(nil, for: .normal)
        
        button.addTarget(self, action: #selector(cardTapped), for: .touchUpInside)
        
        self.button = button
    }
    
    @objc private func cardTapped() {
        
        super.sendEventsToAllViews(eventIds: viewModel.events, rendererState: viewModel.rendererState)
    }
}
