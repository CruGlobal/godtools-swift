//
//  ToolPageModalView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol ToolPageModalViewDelegate: AnyObject {
    
    func toolPageModalListenerActivated(modalView: ToolPageModalView)
    func toolPageModalDismissListenerActivated(modalView: ToolPageModalView)
}

class ToolPageModalView: MobileContentView, NibBased {
    
    private let viewModel: ToolPageModalViewModel
    private let contentStackView: MobileContentStackView
    
    private weak var delegate: ToolPageModalViewDelegate?
    
    @IBOutlet weak private var contentContainerView: UIView!
    
    init(viewModel: ToolPageModalViewModel) {
        
        self.viewModel = viewModel
        self.contentStackView = MobileContentStackView(viewModel: viewModel, contentInsets: .zero, itemSpacing: 15, scrollIsEnabled: true)
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        loadNib()
        setupLayout()
        setupBinding()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // contentStackView
        contentContainerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.constrainEdgesToView(view: contentContainerView)
        setParentAndAddChild(childView: contentStackView)
    }
    
    private func setupBinding() {
        
        backgroundColor = viewModel.backgroundColor
    }
    
    private func centerContentStackVerticallyIfNeeded() {
        
        layoutIfNeeded()
        
        let modalContentSize: CGSize = contentStackView.contentSize
        let shouldCenterVertically: Bool = modalContentSize.height < frame.size.height
        
        if shouldCenterVertically {
            let difference: CGFloat = frame.size.height - modalContentSize.height
            contentStackView.setScrollViewContentInset(contentInset: UIEdgeInsets(top: difference / 2, left: 0, bottom: 0, right: 0))
        }
    }
    
    func setDelegate(delegate: ToolPageModalViewDelegate?) {
        self.delegate = delegate
    }
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
                     
        contentStackView.renderChild(childView: childView)
    }
    
    override func finishedRenderingChildren() {
                
        centerContentStackVerticallyIfNeeded()
    }
    
    override func didReceiveEvent(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
                        
        if viewModel.listeners.contains(eventId) {
            delegate?.toolPageModalListenerActivated(modalView: self)
        }
        else if viewModel.dismissListeners.contains(eventId) {
            delegate?.toolPageModalDismissListenerActivated(modalView: self)
        }
        
        return nil
    }
}
