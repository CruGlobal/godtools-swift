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
    
    required init(rootView: UIViewController) {
        self.rootView = rootView
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
            
        navigationBar.setupNavigationBarAppearance(
            backgroundColor: .white,
            controlColor: nil,
            titleFont: nil,
            titleColor: nil,
            isTranslucent: false
        )
                                
        setViewControllers([rootView], animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
