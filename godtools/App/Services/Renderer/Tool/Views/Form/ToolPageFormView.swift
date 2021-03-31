//
//  ToolPageFormView.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolPageFormView: MobileContentFormView {
    
    static let followUpSendEvent: String = "followup:send"
    
    private let pageFormViewModel: ToolPageFormViewModel
    
    required init(viewModel: ToolPageFormViewModel) {
        
        self.pageFormViewModel = viewModel
        
        super.init(viewModel: viewModel)
        
        setupBinding()
    }
    
    required init(itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: MobileContentFormViewModelType) {
        fatalError("init(viewModel:) has not been implemented")
    }
    
    private func setupBinding() {
        
        pageFormViewModel.didSendFollowUpSignal.addObserver(self) { [weak self] (events: [String]) in
            if let indexForFollowUpEvent = events.firstIndex(of: ToolPageFormView.followUpSendEvent) {
                var eventsWithoutFollowUp: [String] = events
                eventsWithoutFollowUp.remove(at: indexForFollowUpEvent)
                self?.sendEventsToAllViews(events: eventsWithoutFollowUp)
            }
        }
        
        pageFormViewModel.error.addObserver(self) { [weak self] (error: MobileContentErrorViewModel?) in
            if let error = error {
                self?.sendErrorToRootView(error: error)
            }
        }
    }
    
    // MARK: - MobileContenView
    
    override func didReceiveEvents(events: [String]) {
                      
        if events.contains(ToolPageFormView.followUpSendEvent) {
            pageFormViewModel.sendFollowUp(inputModels: super.getInputModels(), events: events)
        }
    }
    
    // MARK: -
}
