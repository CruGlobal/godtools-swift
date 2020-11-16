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
    private let language: LanguageModel
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let followUpsService: FollowUpsService
    private let toolPageColors: ToolPageColorsViewModel
    private let defaultTextNodeTextColor: UIColor?
    
    let contentViewModel: ToolPageContentStackViewModel
    
    required init(formNode: ContentFormNode, manifest: MobileContentXmlManifest, language: LanguageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, localizationServices: LocalizationServices, followUpsService: FollowUpsService, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?) {
        
        self.formNode = formNode
        self.language = language
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.followUpsService = followUpsService
        self.toolPageColors = toolPageColors
        self.defaultTextNodeTextColor = defaultTextNodeTextColor
        
        contentViewModel = ToolPageContentStackViewModel(
            node: formNode,
            manifest: manifest,
            language: language,
            translationsFileCache: translationsFileCache,
            mobileContentNodeParser: mobileContentNodeParser,
            mobileContentAnalytics: mobileContentAnalytics,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            localizationServices: localizationServices,
            followUpsService: followUpsService,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor,
            defaultButtonBorderColor: nil,
            rootContentStack: nil
        )
        
        super.init()
        
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    private func addObservers() {
        
        mobileContentEvents.followUpEventButtonTappedSignal.addObserver(self) { [weak self] (followUpButtonEvent: FollowUpButtonEvent) in
            self?.sendFollowUps(followUpButtonEvent: followUpButtonEvent)
        }
    }
    
    private func removeObservers() {
        mobileContentEvents.followUpEventButtonTappedSignal.removeObserver(self)
        mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
    }
    
    private func sendFollowUps(followUpButtonEvent: FollowUpButtonEvent) {
        
        print("\n SEND FOLLOW UPS")
        
        var inputData: [AnyHashable: Any] = Dictionary()
        var missingFieldsNames: [String] = Array()
        
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
        }
        
        guard missingFieldsNames.isEmpty else {
            notifiyFollowUpsMissingFieldsError(missingFieldsNames: missingFieldsNames)
            return
        }
        
        let name: String? = inputData["name"] as? String
        let email: String? = inputData["email"] as? String
        let destinationId: Int? = Int(inputData["destination_id"] as? String ?? "")
        let languageId: Int? = Int(language.id)
        
        if let name = name, let email = email, let destinationId = destinationId, let languageId = languageId {
            
            let followUpModel = FollowUpModel(
                name: name,
                email: email,
                destinationId: destinationId,
                languageId: languageId
            )
            
            followUpsService.postNewFollowUp(followUp: followUpModel)
            
            for event in followUpButtonEvent.triggerEventsOnFollowUpSent {
                mobileContentEvents.eventButtonTapped(eventButton: ButtonEvent(event: event))
            }
        }
        else {
            
            let errorTitle: String = "Internal Error"
            let errorMessage: String = "Failed to fetch data for follow ups (name, email, destinationId, languageId)."
            
            mobileContentEvents.contentError(error: ContentEventError(title: errorTitle, message: errorMessage))
        }
        
        print("DONE")
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
        
        mobileContentEvents.contentError(error: ContentEventError(title: errorTitle, message: errorMessage))
    }
}
