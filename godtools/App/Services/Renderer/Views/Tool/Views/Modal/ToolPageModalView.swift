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

class ToolPageModalView: MobileContentView {
    
    private let viewModel: ToolPageModalViewModelType
    
    private var contentStackView: MobileContentStackView = MobileContentStackView(contentInsets: .zero, itemSpacing: 15, scrollIsEnabled: true)
    
    private weak var delegate: ToolPageModalViewDelegate?
    
    @IBOutlet weak private var contentContainerView: UIView!
    
    required init(viewModel: ToolPageModalViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    private func initializeNib() {
            
            let nib: UINib = UINib(nibName: String(describing: ToolPageModalView.self), bundle: nil)
            let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
            if let rootNibView = (contents as? [UIView])?.first {
                addSubview(rootNibView)
                rootNibView.backgroundColor = .clear
                rootNibView.frame = bounds
                rootNibView.translatesAutoresizingMaskIntoConstraints = false
                rootNibView.constrainEdgesToSuperview()
            }
        }
    
    private func setupLayout() {
        
        // contentStackView
        contentContainerView.addSubview(contentStackView)
        contentStackView.constrainEdgesToSuperview()
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
    
    override func didReceiveEvents(eventIds: [EventId]) {
            
        let eventsContainFollowUp: Bool = eventIds.contains(EventId.Companion().FOLLOWUP)
        
        for eventId in eventIds {
            
            if viewModel.listeners.contains(eventId) && !eventsContainFollowUp {
                delegate?.toolPageModalListenerActivated(modalView: self)
            }
            else if viewModel.dismissListeners.contains(eventId) {
                delegate?.toolPageModalDismissListenerActivated(modalView: self)
            }
        }
    }
}
