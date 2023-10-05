//
//  AppInterfaceStringNavBarItemController.swift
//  godtools
//
//  Created by Levi Eggert on 10/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

class AppInterfaceStringNavBarItemController: NarBarItemController {
        
    private let interfaceStringBarItem: AppInterfaceStringBarItem
    private let getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase
    private let toggleVisibility: AnyPublisher<Bool, Never>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(viewController: UIViewController, navBarItem: AppInterfaceStringBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int, getInterfaceStringInAppLanguageUseCase: GetInterfaceStringInAppLanguageUseCase) {
               
        self.interfaceStringBarItem = navBarItem
        self.getInterfaceStringInAppLanguageUseCase = getInterfaceStringInAppLanguageUseCase
        self.toggleVisibility = navBarItem.toggleVisibilityPublisher ?? CurrentValueSubject<Bool, Never>(false).eraseToAnyPublisher()
        
        super.init(
            viewController: viewController,
            navBarItem: navBarItem,
            itemBarPosition: itemBarPosition,
            itemIndex: itemIndex,
            shouldSinkToggleVisibility: false
        )
        
        Publishers.CombineLatest(
            toggleVisibility,
            getInterfaceStringInAppLanguageUseCase.observeStringChangedPublisher(id: interfaceStringBarItem.localizedStringKey)
        )
        .receive(on: DispatchQueue.main)
        .sink{ [weak self] (hidden: Bool, interfaceString: String) in
            
            if hidden {
                self?.setHidden(hidden: hidden)
            }
            else if let newBarButtonItem = self?.interfaceStringBarItem.itemData.getNewBarButtonItem(contentType: .title(value: interfaceString)) {
                self?.setBarButtonItem(barButtonItem: newBarButtonItem)
            }
        }
        .store(in: &cancellables)
    }
}
