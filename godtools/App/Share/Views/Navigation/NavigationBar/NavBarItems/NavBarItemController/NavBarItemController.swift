//
//  NavBarItemController.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import Combine

protocol NavBarItemControllerDelegate: AnyObject {
    
    func didChangeBarButtonItemState(controller: NavBarItemController)
}

class NavBarItemController {
        
    private var hidesBarItemPublisher: AnyPublisher<Bool, Never>?
    private var barButtonItem: UIBarButtonItem?
    private var cancellables: Set<AnyCancellable> = Set()
    
    private(set) var barButtonItemIsHidden: Bool = true
    
    private weak var delegate: NavBarItemControllerDelegate?
    
    let navBarItem: NavBarItem
    let itemBarPosition: BarButtonItemBarPosition
    let itemIndex: Int
    
    init(delegate: NavBarItemControllerDelegate, navBarItem: NavBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int) {
        
        self.delegate = delegate
        self.navBarItem = navBarItem
        self.itemBarPosition = itemBarPosition
        self.itemIndex = itemIndex
        
        let newBarButtonItem: UIBarButtonItem = navBarItem.itemData.getNewBarButtonItem()
        
        self.hidesBarItemPublisher = navBarItem.hidesBarItemPublisher
        self.barButtonItem = newBarButtonItem
                
        if let hidesBarItemPublisher = navBarItem.hidesBarItemPublisher {
            
            hidesBarItemPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (hidden: Bool) in
                    self?.setHidden(hidden: hidden)
                }
                .store(in: &cancellables)
        }
        else {
            
            setHidden(hidden: false)
        }
    }
    
    static func newNavBarItemController(controllerType: NavBarItemControllerType, delegate: NavBarItemControllerDelegate, navBarItem: NavBarItem, itemBarPosition: BarButtonItemBarPosition, itemIndex: Int) -> NavBarItemController {
        
        let navBarItemController: NavBarItemController?
        
        switch controllerType {
       
        case .appInterfaceString(let getInterfaceStringInAppLanguageUseCase):
            
            if let interfaceStringBarItem = navBarItem as? AppInterfaceStringBarItem {
                
                navBarItemController = AppInterfaceStringNavBarItemController(
                    delegate: delegate,
                    navBarItem: interfaceStringBarItem,
                    itemBarPosition: itemBarPosition,
                    itemIndex: itemIndex,
                    getInterfaceStringInAppLanguageUseCase: getInterfaceStringInAppLanguageUseCase
                )
            }
            else {
                
                assertionFailure("Failed to create NavBarItemController with appInterfaceString type.  Requires AppInterfaceStringBarItem.")
                
                navBarItemController = nil
            }
            
        case .appLayoutDirection(let layoutDirectionPublisher):
            
            if let layoutDirectionBasedNavBarItem = navBarItem as? AppLayoutDirectionBasedBarItem {
                
                navBarItemController = AppLayoutDirectionNavBarItemController(
                    delegate: delegate,
                    navBarItem: layoutDirectionBasedNavBarItem,
                    itemBarPosition: itemBarPosition,
                    itemIndex: itemIndex,
                    layoutDirectionPublisher: layoutDirectionPublisher
                )
            }
            else {
                
                assertionFailure("Failed to create NavBarItemController with appLayoutDirection type.  Requires AppLayoutDirectionBasedBarItem.")
                
                navBarItemController = nil
            }
            
        case .base:
            navBarItemController = nil
        }
        
        if let navBarItemController = navBarItemController {
            return navBarItemController
        }
        
        return NavBarItemController(
            delegate: delegate,
            navBarItem: navBarItem,
            itemBarPosition: itemBarPosition,
            itemIndex: itemIndex
        )
    }

    func getBarButtonItem() -> UIBarButtonItem? {
        return barButtonItem
    }
    
    func reDrawBarButtonItem(barButtonItem: UIBarButtonItem) {
        
        self.barButtonItem = barButtonItem
                    
        delegate?.didChangeBarButtonItemState(controller: self)
    }
    
    private func setHidden(hidden: Bool) {
        
        barButtonItemIsHidden = hidden
        
        delegate?.didChangeBarButtonItemState(controller: self)
    }
}
