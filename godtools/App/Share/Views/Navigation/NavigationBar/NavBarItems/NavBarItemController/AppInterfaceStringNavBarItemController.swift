//
//  AppInterfaceStringNavBarItemController.swift
//  godtools
//
//  Created by Levi Eggert on 10/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppInterfaceStringNavBarItemController: NavBarItemController {
        
    private let interfaceStringBarItem: AppInterfaceStringBarItem
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    
    private var currentInterfaceString: String?
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(delegate: NavBarItemControllerDelegate, navBarItem: AppInterfaceStringBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase) {
               
        self.interfaceStringBarItem = navBarItem
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        
        super.init(
            delegate: delegate,
            navBarItem: navBarItem,
            itemBarPosition: itemBarPosition,
            itemIndex: itemIndex
        )
        
        getInterfaceStringInAppLanguageUseCase.getStringPublisher(id: interfaceStringBarItem.localizedStringKey)
        .receive(on: DispatchQueue.main)
        .sink{ [weak self] (interfaceString: String) in
            
            let shouldRedraw: Bool = self?.currentInterfaceString != interfaceString
            
            if shouldRedraw, let newBarButtonItem = self?.interfaceStringBarItem.itemData.getNewBarButtonItem(contentType: .title(value: interfaceString)) {
                
                self?.reDrawBarButtonItem(barButtonItem: newBarButtonItem)
            }
            
            self?.currentInterfaceString = interfaceString
        }
        .store(in: &cancellables)
    }
}
