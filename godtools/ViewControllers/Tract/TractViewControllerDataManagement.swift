//
//  TractViewControllerDataManagement.swift
//  godtools
//
//  Created by Devserker on 5/30/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

extension TractViewController {
    
    // MARK: - Management of languages
    
    func parallelLanguageIsAvailable() -> Bool {
        if parallelLanguage == nil {
            return false
        }
        
        return resource!.isDownloadedInLanguage(parallelLanguage)
    }
    
    func determinePrimaryLabel() -> String {
        let primaryLanguage = resolvePrimaryLanguage()
        
        if primaryLanguage == nil {
            return Locale.current.localizedString(forLanguageCode: Locale.current.languageCode!)!
        } else {
            return primaryLanguage!.localizedName()
        }
    }
    
    func determineParallelLabel() -> String {
        return parallelLanguage!.localizedName()
    }
    
    func getLanguageTextAlignment() -> NSTextAlignment {
        return .left
    }
    
    // MARK: - Management of resources
    
    func getResourceData() {
        loadResourcesForLanguage()
        loadResourcesForParallelLanguage()
        usePrimaryLanguageResources()
        loadPagesIds()
    }
    
    func loadResourcesForLanguage() {
        guard let language = resolvePrimaryLanguage() else { return }
        guard let resource = resource else { return }
        let content = self.tractsManager.loadResource(resource: resource, language: language)
        self.xmlPagesForPrimaryLang = content.pages
        self.manifestProperties = content.manifestProperties
    }
    
    func loadResourcesForParallelLanguage() {
        if parallelLanguageIsAvailable() {
            let content = self.tractsManager.loadResource(resource: self.resource!, language: parallelLanguage!)
            self.xmlPagesForParallelLang = content.pages
        }
    }
    
    func loadPagesIds() {
        var counter = 0
        for page in self.xmlPages {
            guard let pageListeners = page.pageListeners() else { continue }
            for listener in pageListeners {
                TractBindings.addPageBinding(listener, counter)
            }
            
            counter += 1
        }
    }
    
    func usePrimaryLanguageResources() {
        self.selectedLanguage = resolvePrimaryLanguage()
        self.xmlPages = self.xmlPagesForPrimaryLang
    }
    
    func useParallelLanguageResources() {
        self.selectedLanguage = parallelLanguage
        self.xmlPages = self.xmlPagesForParallelLang
    }
    
    func getPage(_ pageNumber: Int) -> XMLPage {
        return self.xmlPages[pageNumber]
    }
    
    func totalPages() -> Int {
        return self.xmlPages.count;
    }
}
