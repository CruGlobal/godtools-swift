//
//  MenuViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import TheKeyOAuthSwift
import GTMAppAuth

class MenuViewModel: NSObject, MenuViewModelType {
    
    private let menuProvider: MenuProviderType
    private let supportedLanguageCodes: [String] = ["en"]
    
    let loginClient: TheKeyOAuthClient
    let menuDataSource: ObservableValue<MenuDataSource> = ObservableValue(value: MenuDataSource.emptyData)
    
    required init(loginClient: TheKeyOAuthClient, menuProvider: MenuProviderType) {
        
        self.loginClient = loginClient
        self.menuProvider = menuProvider
        
        super.init()
                
        reloadMenuDataSource()
    }
    
    func reloadMenuDataSource() {
        
        let currentLanguageCode: String = Locale.current.languageCode ?? "unknown"
        let generalMenuSectionId: GeneralMenuSectionId
        
        if supportedLanguageCodes.contains(currentLanguageCode) {
            generalMenuSectionId = loginClient.isAuthenticated() ? .authorized : .unauthorized
        }
        else {
            generalMenuSectionId = .nonSupportedLanguage
        }
        
        menuDataSource.accept(value: menuProvider.getMenuDataSource(generalMenuSectionId: generalMenuSectionId))
    }
}
