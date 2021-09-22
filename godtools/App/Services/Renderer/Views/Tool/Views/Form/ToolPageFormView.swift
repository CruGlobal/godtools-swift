//
//  ToolPageFormView.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolPageFormView: MobileContentFormView {
        
    private let pageFormViewModel: ToolPageFormViewModel
    
    required init(viewModel: ToolPageFormViewModel) {
        
        self.pageFormViewModel = viewModel
        
        super.init(viewModel: viewModel)
        
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: MobileContentFormViewModelType) {
        fatalError("init(viewModel:) has not been implemented")
    }
    
    required init(contentInsets: UIEdgeInsets, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(contentInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    private func setupBinding() {
        
        pageFormViewModel.didSendFollowUpSignal.addObserver(self) { [weak self] (eventIds: [MultiplatformEventId]) in
            
            guard let formView = self else {
                return
            }
            
            if let indexForFollowUpEvent = eventIds.firstIndex(of: MultiplatformEventId.followUp) {
                var eventsWithoutFollowUp: [MultiplatformEventId] = eventIds
                eventsWithoutFollowUp.remove(at: indexForFollowUpEvent)
                formView.sendEventsToAllViews(eventIds: eventsWithoutFollowUp, rendererState: formView.pageFormViewModel.rendererState)
                formView.resignCurrentEditedTextField()
            }
        }
        
        pageFormViewModel.error.addObserver(self) { [weak self] (error: MobileContentErrorViewModel?) in
            if let error = error {
                self?.sendErrorToRootView(error: error)
            }
        }
    }
    
    // MARK: - MobileContenView
    
    override func didReceiveEvents(eventIds: [MultiplatformEventId]) {
                      
        if eventIds.contains(MultiplatformEventId.followUp) {
            pageFormViewModel.sendFollowUp(inputModels: super.getInputModels(), eventIds: eventIds)
        }
    }
    
    // MARK: -
}
