//
//  ToolPageContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentFormViewModel: NSObject, ToolPageContentFormViewModelType {
    
    private let formNode: ContentFormNode
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    
    let resignCurrentInputSignal: Signal = Signal()
    let contentViewModel: ToolPageContentStackViewModel
    
    required init(formNode: ContentFormNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?) {
        
        self.formNode = formNode
        self.diContainer = diContainer
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        
        contentViewModel = ToolPageContentStackViewModel(
            node: formNode,
            diContainer: diContainer,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor,
            defaultTextNodeTextAlignment: nil,
            defaultButtonBorderColor: nil
        )
        
        super.init()
        
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    private func addObservers() {
        
        diContainer.mobileContentEvents.followUpEventButtonTappedSignal.addObserver(self) { [weak self] (followUpButtonEvent: FollowUpButtonEvent) in
            self?.sendFollowUps(followUpButtonEvent: followUpButtonEvent)
        }
    }
    
    private func removeObservers() {
        diContainer.mobileContentEvents.followUpEventButtonTappedSignal.removeObserver(self)
        diContainer.mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
    }
    
    private func sendFollowUps(followUpButtonEvent: FollowUpButtonEvent) {
            
        resignCurrentInputSignal.accept()
        
        var inputData: [AnyHashable: Any] = Dictionary()
        var missingFieldsNames: [String] = Array()
        
        // TODO: Implement. ~Levi
        /*
        for hiddenInputNode in contentViewModel.hiddenInputNodes {
            
            let name: String? = hiddenInputNode.name
            let value: String? = hiddenInputNode.value
            
            if let name = name, let value = value {
                inputData[name] = value
            }
        }
        
        for inputViewModel in contentViewModel.inputViewModels {
            
            let name: String? = inputViewModel.inputNode.name
            let value: String? = inputViewModel.inputValue
            let inputIsRequired: Bool = inputViewModel.inputNode.required == "true"
            let inputValueIsMissing: Bool = (inputViewModel.inputValue?.isEmpty) ?? true
            
            if let name = name, let value = value {
                inputData[name] = value
            }
            
            if inputIsRequired && inputValueIsMissing, let name = name {
                missingFieldsNames.append(name)
            }
        }*/
        
        guard missingFieldsNames.isEmpty else {
            notifiyFollowUpsMissingFieldsError(missingFieldsNames: missingFieldsNames)
            return
        }
        
        let name: String? = inputData["name"] as? String
        let email: String? = inputData["email"] as? String
        let destinationId: Int? = Int(inputData["destination_id"] as? String ?? "")
        let languageId: Int? = Int(diContainer.language.id)
        
        if let name = name, let email = email, let destinationId = destinationId, let languageId = languageId {
            
            let followUpModel = FollowUpModel(
                name: name,
                email: email,
                destinationId: destinationId,
                languageId: languageId
            )
            
            diContainer.followUpsService.postNewFollowUp(followUp: followUpModel)
            
            for event in followUpButtonEvent.triggerEventsOnFollowUpSent {
                diContainer.mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
            }
        }
        else {
            
            let errorTitle: String = "Internal Error"
            let errorMessage: String = "Failed to fetch data for follow ups (name, email, destinationId, languageId)."
            
            diContainer.mobileContentEvents.contentError(error: ContentEventError(title: errorTitle, message: errorMessage))
        }
    }
    
    private func notifiyFollowUpsMissingFieldsError(missingFieldsNames: [String]) {
        
        let errorTitle: String = diContainer.localizationServices.stringForMainBundle(key: "error")
        var errorMessage: String = ""
        
        for index in 0 ..< missingFieldsNames.count {
            let name: String = missingFieldsNames[index]
            
            if index > 0 {
                errorMessage += "\n"
            }
            
            errorMessage += String(format: diContainer.localizationServices.stringForMainBundle(key: "required_field_missing"), name.localizedCapitalized)
        }
        
        diContainer.mobileContentEvents.contentError(error: ContentEventError(title: errorTitle, message: errorMessage))
    }
}
