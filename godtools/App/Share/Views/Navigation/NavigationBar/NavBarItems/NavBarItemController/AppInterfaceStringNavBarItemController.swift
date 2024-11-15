//
//  AppInterfaceStringNavBarItemController.swift
//  godtools
//
//  Created by Levi Eggert on 10/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine
import LocalizationServices

class AppInterfaceStringNavBarItemController: NavBarItemController {
        
    private let interfaceStringBarItem: AppInterfaceStringBarItem
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let localizationServices: LocalizationServicesInterface
    
    private var currentInterfaceString: String?
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(delegate: NavBarItemControllerDelegate, navBarItem: AppInterfaceStringBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int, getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase, localizationServices: LocalizationServicesInterface) {
               
        self.interfaceStringBarItem = navBarItem
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.localizationServices = localizationServices
        
        super.init(
            delegate: delegate,
            navBarItem: navBarItem,
            itemBarPosition: itemBarPosition,
            itemIndex: itemIndex
        )
        
        let localizedStringKey: String = interfaceStringBarItem.localizedStringKey
        
        getCurrentAppLanguageUseCase.getLanguagePublisher()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                let interfaceString: String = localizationServices.stringForLocaleElseEnglish(
                    localeIdentifier: appLanguage,
                    key: localizedStringKey
                )
                
                return Just(interfaceString)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (interfaceString: String) in
                
                let shouldRedraw: Bool = self?.currentInterfaceString != interfaceString
                
                if shouldRedraw, let newBarButtonItem = self?.interfaceStringBarItem.itemData.getNewBarButtonItem(contentType: .title(value: interfaceString)) {
                    
                    self?.reDrawBarButtonItem(barButtonItem: newBarButtonItem)
                }
                
                self?.currentInterfaceString = interfaceString
            }
            .store(in: &cancellables)
    }
}
