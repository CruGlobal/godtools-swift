//
//  ToolPageFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class ToolPageFormViewModel: MobileContentFormViewModel {
    
    private let rendererPageModel: MobileContentRendererPageModel
    private let followUpService: FollowUpsService
    private let localizationServices: LocalizationServices
    
    let didSendFollowUpSignal: SignalValue<[EventId]> = SignalValue()
    let error: ObservableValue<MobileContentErrorViewModel?> = ObservableValue(value: nil)
    
    required init(formModel: Form, rendererPageModel: MobileContentRendererPageModel, followUpService: FollowUpsService, localizationServices: LocalizationServices) {
        
        self.rendererPageModel = rendererPageModel
        self.followUpService = followUpService
        self.localizationServices = localizationServices
        
        super.init(formModel: formModel, rendererPageModel: rendererPageModel)
    }
    
    required init(formModel: Form, rendererPageModel: MobileContentRendererPageModel) {
        fatalError("init(formModel:rendererPageModel:) has not been implemented")
    }
    
    var rendererState: State {
        return rendererPageModel.rendererState
    }
    
    // MARK: - Follow Up
    
    func sendFollowUp(inputModels: [MobileContentFormInputModel], eventIds: [EventId]) {
           
        let destinationIdField: String = "destination_id"
        let nameField: String = "name"
        let emailField: String = "email"
        
        var destinationId: Int = -1
        var name: String = ""
        var email: String = ""
        
        var missingFieldsNames: [String] = Array()
        
        for inputModel in inputModels {
            
            let inputName: String = inputModel.name
            
            if inputName == destinationIdField, let destinationIdValue = Int(inputModel.value) {
                destinationId = destinationIdValue
            }
            else if inputName == nameField {
                name = inputModel.value
            }
            else if inputName == emailField {
                email = inputModel.value
            }
            
            if inputModel.isRequired && inputModel.value.isEmpty {
                
                missingFieldsNames.append(inputName)
            }
        }
        
        guard missingFieldsNames.isEmpty else {
            notifiyFollowUpsMissingFieldsError(missingFieldsNames: missingFieldsNames)
            return
        }
        
        
        let languageId: Int = Int(rendererPageModel.language.id) ?? 0
        
        let followUpModel = FollowUpModel(
            name: name,
            email: email,
            destinationId: destinationId,
            languageId: languageId
        )
        
        _ = followUpService.postNewFollowUp(followUp: followUpModel)
        
        didSendFollowUpSignal.accept(value: eventIds)
    }
    
    private func notifiyFollowUpsMissingFieldsError(missingFieldsNames: [String]) {
        
        let errorTitle: String = localizationServices.stringForMainBundle(key: "error")
        var errorMessage: String = ""
        
        for index in 0 ..< missingFieldsNames.count {
            let name: String = missingFieldsNames[index]
            
            if index > 0 {
                errorMessage += "\n"
            }
            
            errorMessage += String(format: localizationServices.stringForMainBundle(key: "required_field_missing"), name.localizedCapitalized)
        }
        
        let errorViewModel = MobileContentErrorViewModel(
            title: errorTitle,
            message: errorMessage,
            localizationServices: localizationServices
        )
        
        error.accept(value: errorViewModel)
    }
}
