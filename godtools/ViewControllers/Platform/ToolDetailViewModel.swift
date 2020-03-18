//
//  ToolDetailViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolDetailViewModel: ToolDetailViewModelType {
    
    private let analytics: GodToolsAnaltyics
    
    private weak var flowDelegate: FlowDelegate?
    
    let resource: DownloadedResource
    let hidesOpenToolButton: Bool
    
    required init(flowDelegate: FlowDelegate, resource: DownloadedResource, analytics: GodToolsAnaltyics) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.analytics = analytics
        self.hidesOpenToolButton = !resource.shouldDownload
    }
    
    func urlTapped(url: URL) {
        
        analytics.recordExitLinkAction(url: url)
        
        flowDelegate?.navigate(step: .urlLinkTappedFromToolDetail(url: url))
    }
    
    var aboutDetails: String {
        
        let resourceDescription: String = resource.descr ?? ""
        
        let languagesManager = LanguagesManager()
        
        var languageOrder: [Language] = Array()
        
        if let primaryLanguage = languagesManager.loadPrimaryLanguageFromDisk() {
            languageOrder.append(primaryLanguage)
        }
        
        if let deviceLanguage = languagesManager.loadDevicePreferredLanguageFromDisk() {
            languageOrder.append(deviceLanguage)
        }
        
        if let englishLanguage = languagesManager.loadFromDisk(id: "en") {
            languageOrder.append(englishLanguage)
        }
        
        for language in languageOrder {
            if let translation = resource.getTranslationForLanguage(language) {
                if let description = translation.localizedDescription, !description.isEmpty {
                    return description
                }
            }
        }
        
        return resourceDescription
    }
    
    var languageDetails: String {
        
        let primaryLanguage = LanguagesManager().loadPrimaryLanguageFromDisk()
        let languageCode = primaryLanguage?.code ?? "en"
        let locale = resource.isAvailableInLanguage(primaryLanguage) ? Locale(identifier:  languageCode) : Locale.current
        let resourceTranslations: [Translation] = Array(resource.translations)
        var translationStrings: [String] = []
        
        for translation in resourceTranslations {
            guard translation.language != nil else {
                continue
            }
            guard let languageLocalName = translation.language?.localizedName(locale: locale) else {
                continue
            }
            translationStrings.append(languageLocalName)
        }
        
        return translationStrings.sorted(by: { $0 < $1 }).joined(separator: ", ")
    }
}
