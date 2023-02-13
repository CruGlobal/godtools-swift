//
//  ModalNavigationController.swift
//  godtools
//
//  Created by Levi Eggert on 6/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ModalNavigationController: UINavigationController {
    
    private static let defaultNavBarColor: UIColor = .white
    private static let defaultNavBarIsTranslucent = false
    
    private let rootView: UIViewController
    private let navBarColor: UIColor
    private let navBarIsTranslucent: Bool
    
    required init(rootView: UIViewController, navBarColor: UIColor = ModalNavigationController.defaultNavBarColor, navBarIsTranslucent: Bool = ModalNavigationController.defaultNavBarIsTranslucent) {
        
        self.rootView = rootView
        self.navBarColor = navBarColor
        self.navBarIsTranslucent = navBarIsTranslucent
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationBar.setupNavigationBarAppearance(backgroundColor: navBarColor, controlColor: nil, titleFont: nil, titleColor: nil, isTranslucent: navBarIsTranslucent)
                                
        setViewControllers([rootView], animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return .default
    }
}
