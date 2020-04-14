//
//  AboutView.swift
//  godtools
//
//  Created by Levi Eggert on 4/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class AboutView: UIViewController {
    
    private let viewModel: AboutViewModelType
        
    required init(viewModel: AboutViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "AboutView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        setupBinding()
        
        addDefaultNavBackItem()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        title = viewModel.navTitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
}
