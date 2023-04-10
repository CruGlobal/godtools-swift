//
//  ModalNavigationController.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ModalNavigationController: UINavigationController {
        
    private let rootView: UIViewController
    
    static func defaultModal(rootView: UIViewController) -> ModalNavigationController {
        
        return ModalNavigationController(
            rootView: rootView,
            navBarColor: UIColor.white,
            navBarIsTranslucent: false,
            controlColor: ColorPalette.gtBlue.uiColor
        )
    }
    
    init(rootView: UIViewController, navBarColor: UIColor, navBarIsTranslucent: Bool, controlColor: UIColor) {
        
        self.rootView = rootView
        
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
        
        return .default
    }
}
