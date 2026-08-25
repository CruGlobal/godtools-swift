//
//  AppViewController.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

@MainActor
class AppViewController: UIViewController {
    
    private let navigationBar: AppNavigationBar?
    
    init(navigationBar: AppNavigationBar?) {
          
        self.navigationBar = navigationBar
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(nibName: String?, bundle: Bundle?, navigationBar: AppNavigationBar?) {
        
        self.navigationBar = navigationBar
        
        super.init(nibName: nibName, bundle: bundle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        navigationBar?.willAppear(viewController: self, animated: animated)
    }
}
