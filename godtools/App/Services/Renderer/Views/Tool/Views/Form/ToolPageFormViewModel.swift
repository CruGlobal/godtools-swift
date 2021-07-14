//
//  ToolPageFormViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/23/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class ToolPageFormViewModel: MobileContentFormViewModel {
    
    private let pageModel: MobileContentRendererPageModel
    private let followUpService: FollowUpsService
    private let localizationServices: LocalizationServices
    
    let didSendFollowUpSignal: SignalValue<[String]> = SignalValue()
    let error: ObservableValue<MobileContentErrorViewModel?> = ObservableValue(value: nil)
    
    required init(formModel: ContentFormModelType, pageModel: MobileContentRendererPageModel, followUpService: FollowUpsService, localizationServices: LocalizationServices) {
        
        self.pageModel = pageModel
        self.followUpService = followUpService
        self.localizationServices = localizationServices
        
        super.init(formModel: formModel, pageModel: pageModel)
    }
    
    required init(formModel: ContentFormModelType, pageModel: MobileContentRendererPageModel) {
        fatalError("init(formModel:pageModel:) has not been implemented")
    }
    
    // MARK: - Follow Up
    
    func sendFollowUp(inputModels: [MobileContentFormInputModel], events: [String]) {
           
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
        
        
        let languageId: Int = Int(pageModel.language.id) ?? 0
        
        let followUpModel = FollowUpModel(
            name: name,
            email: email,
            destinationId: destinationId,
            languageId: languageId
        )
        
        _ = followUpService.postNewFollowUp(followUp: followUpModel)
        
        didSendFollowUpSignal.accept(value: events)
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
