//
//  ToolPageFormView.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class ToolPageFormView: MobileContentFormView {
        
    private let pageFormViewModel: ToolPageFormViewModel
    
    init(viewModel: ToolPageFormViewModel) {
        
        self.pageFormViewModel = viewModel
        
        super.init(viewModel: viewModel)
        
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBinding() {
        
        pageFormViewModel.didSendFollowUpSignal.addObserver(self) { [weak self] (eventIds: [EventId]) in
            
            guard let formView = self else {
                return
            }
            
            if let indexForFollowUpEvent = eventIds.firstIndex(of: EventId.Companion().FOLLOWUP) {
                var eventsWithoutFollowUp: [EventId] = eventIds
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
    
    override func didReceiveAncestryEventFromWalkingUpViewHierarchy(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
        
        let isFollowUpEvent: Bool = eventId == EventId.Companion().FOLLOWUP
                
        if isFollowUpEvent {
            pageFormViewModel.sendFollowUp(inputModels: super.getInputModels(), eventIds: eventIdsGroup)
            return ProcessedEventResult(shouldRemoveEventId: true)
        }
        
        return nil
    }
}
