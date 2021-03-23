//
//  MobileContentFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentFormViewModel: NSObject, MobileContentFormViewModelType {
    
    private let formNode: ContentFormNode
    private let pageModel: MobileContentRendererPageModel
    
    private var hiddenInputNodes: [ContentInputNode] = Array()
    private var inputViewModels: [MobileContentInputViewModelType] = Array()
        
    required init(formNode: ContentFormNode, pageModel: MobileContentRendererPageModel) {
        
        self.formNode = formNode
        self.pageModel = pageModel

        super.init()
        
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    private func addObservers() {
        
        /*
        diContainer.mobileContentEvents.followUpEventButtonTappedSignal.addObserver(self) { [weak self] (followUpButtonEvent: FollowUpButtonEvent) in
            self?.sendFollowUps(followUpButtonEvent: followUpButtonEvent)
        }
        
        contentViewModel.contentStackRenderer.didRenderHiddenContentInputSignal.addObserver(self) { [weak self] (hiddenInputNode: ContentInputNode) in
            self?.hiddenInputNodes.append(hiddenInputNode)
        }
        
        contentViewModel.contentStackRenderer.didRenderContentInputSignal.addObserver(self) { [weak self] (renderedInput: ToolPageRenderedContentInput) in
            self?.inputViewModels.append(renderedInput.viewModel)
        }*/
    }
    
    private func removeObservers() {
        
        //diContainer.mobileContentEvents.followUpEventButtonTappedSignal.removeObserver(self)
        //diContainer.mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
        //contentViewModel.contentStackRenderer.didRenderHiddenContentInputSignal.removeObserver(self)
        //contentViewModel.contentStackRenderer.didRenderContentInputSignal.removeObserver(self)
    }
    
    /*
    private func sendFollowUps(followUpButtonEvent: FollowUpButtonEvent) {
            
        resignCurrentInputSignal.accept()
        
        var inputData: [String: Any] = Dictionary()
        var missingFieldsNames: [String] = Array()
                
        for hiddenInputNode in hiddenInputNodes {
            
            let name: String? = hiddenInputNode.name
            let value: String? = hiddenInputNode.value
            
            if let name = name, let value = value {
                inputData[name] = value
            }
        }
        
        for inputViewModel in inputViewModels {
            
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
        }
        
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
    }*/
}
