//
//  AppViewController.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class AppViewController: UIViewController {
    
    private let navigationBar: AppNavigationBar?
    
    init(navigationBar: AppNavigationBar?) {
          
        self.navigationBar = navigationBar
        
        super.init(nibName: nil, bundle: nil)
        
        navigationBar?.configure(viewController: self)
    }
    
    init(nibName: String?, bundle: Bundle?, navigationBar: AppNavigationBar?) {
        
        self.navigationBar = navigationBar
        
        super.init(nibName: nibName, bundle: bundle)
        
        navigationBar?.configure(viewController: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBar?.willAppear(animated: animated)
    }
}
