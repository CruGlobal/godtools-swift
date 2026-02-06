//
//  DashboardFlow+Menu.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit

extension DashboardFlow {
    
    func navigateToMenu(animated: Bool, initialNavigationStep: FlowStep? = nil) {
        
        let menuFlow: MenuFlow = MenuFlow(
            flowDelegate: self,
            appDiContainer: appDiContainer,
            initialNavigationStep: initialNavigationStep
        )
        
        self.menuFlow = menuFlow
        
        rootController.addChildController(child: menuFlow.navigationController)
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        let menuView: UIView = menuFlow.navigationController.view
        let appView: UIView = navigationController.view
        
        let menuViewStartingX: CGFloat
        let menuViewEndingX: CGFloat = 0
        let appViewEndingX: CGFloat
        
        switch ApplicationLayout.shared.currentDirection {
       
        case .leftToRight:
            menuViewStartingX = screenWidth * -1
            appViewEndingX = screenWidth
            
        case .rightToLeft:
            menuViewStartingX = screenWidth
            appViewEndingX = screenWidth * -1
        }
        
        menuView.frame = CGRect(x: menuViewStartingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
        
        if animated {
                                                
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                
                menuView.frame = CGRect(x: menuViewEndingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
                appView.frame = CGRect(x: appViewEndingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
                                
            }, completion: nil)
        }
        else {
            
            menuView.frame = CGRect(x: menuViewEndingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
            appView.frame = CGRect(x: appViewEndingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
        }
    }
    
    func closeMenu(animated: Bool) {
           
        guard let menuFlow = self.menuFlow else {
            return
        }
        
        menuFlow.navigationController.dismiss(animated: animated, completion: nil)
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        let menuView: UIView = menuFlow.navigationController.view
        let appView: UIView = navigationController.view
        
        let menuViewStartingX: CGFloat = 0
        let menuViewEndingX: CGFloat
        let appViewStartingX: CGFloat
        let appViewEndingX: CGFloat = 0
        
        switch ApplicationLayout.shared.currentDirection {
       
        case .leftToRight:
            menuViewEndingX = screenWidth * -1
            appViewStartingX = screenWidth
            
        case .rightToLeft:
            menuViewEndingX = screenWidth
            appViewStartingX = screenWidth * -1
        }
        
        menuView.frame = CGRect(x: menuViewStartingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
        appView.frame = CGRect(x: appViewStartingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
                
        if animated {
            
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                                
                menuView.frame = CGRect(x: menuViewEndingX, y: 0, width: menuView.frame.size.width, height: menuView.frame.size.height)
                appView.frame = CGRect(x: appViewEndingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
                
            }, completion: { [weak self] ( finished: Bool) in
                
                menuFlow.navigationController.removeAsChildController()
                self?.menuFlow = nil
            })
        }
        else {
                        
            appView.frame = CGRect(x: appViewEndingX, y: 0, width: appView.frame.size.width, height: appView.frame.size.height)
            
            menuFlow.navigationController.removeAsChildController()
            self.menuFlow = nil
        }
    }
}
