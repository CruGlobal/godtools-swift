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
    
    private let followUpService: FollowUpsService
    private let localizationServices: LocalizationServices
    
    let didSendFollowUpSignal: SignalValue<[EventId]> = SignalValue()
    let error: ObservableValue<MobileContentErrorViewModel?> = ObservableValue(value: nil)
    
    init(formModel: Form, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics, followUpService: FollowUpsService, localizationServices: LocalizationServices) {
        
        self.followUpService = followUpService
        self.localizationServices = localizationServices
        
        super.init(formModel: formModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
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
        
        
        let languageId: Int = Int(renderedPageContext.language.id) ?? 0
        
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
        
        let appLanguage: AppLanguageDomainModel = renderedPageContext.appLanguage
        
        let errorTitle: String = localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.error.key)
        var errorMessage: String = ""
        
        for index in 0 ..< missingFieldsNames.count {
            let name: String = missingFieldsNames[index]
            
            if index > 0 {
                errorMessage += "\n"
            }
            
            errorMessage += String(format: localizationServices.stringForLocaleElseEnglish(localeIdentifier: appLanguage, key: LocalizableStringKeys.requiredMissingField.key), name.localizedCapitalized)
        }
        
        let errorViewModel = MobileContentErrorViewModel(
            appLanguage: appLanguage,
            title: errorTitle,
            message: errorMessage,
            localizationServices: localizationServices
        )
        
        error.accept(value: errorViewModel)
    }
}
