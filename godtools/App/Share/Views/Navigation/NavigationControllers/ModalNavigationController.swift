//
//  ModalNavigationController.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ModalNavigationController: AppNavigationController {
        
    private let rootView: UIViewController
    private let statusBarStyle: UIStatusBarStyle
    
    static func defaultModal(rootView: UIViewController, statusBarStyle: UIStatusBarStyle) -> ModalNavigationController {
        
        return ModalNavigationController(
            rootView: rootView,
            navBarColor: UIColor.white,
            navBarIsTranslucent: false,
            controlColor: ColorPalette.gtBlue.uiColor,
            statusBarStyle: statusBarStyle
        )
    }
    
    init(rootView: UIViewController, navBarColor: UIColor, navBarIsTranslucent: Bool, controlColor: UIColor, statusBarStyle: UIStatusBarStyle) {
        
        self.rootView = rootView
        self.statusBarStyle = statusBarStyle
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
        
        navigationBar.setupNavigationBarAppearance(
            backgroundColor: navBarColor,
            controlColor: controlColor,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: navBarIsTranslucent
        )
                                
        setViewControllers([rootView], animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        print("x deinit: \(type(of: self))")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return statusBarStyle
    }
}
