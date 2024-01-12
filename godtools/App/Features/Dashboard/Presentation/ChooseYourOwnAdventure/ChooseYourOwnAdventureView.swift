//
//  ChooseYourOwnAdventureView.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class ChooseYourOwnAdventureView: MobileContentPagesView {
    
    private let viewModel: ChooseYourOwnAdventureViewModel
        
    init(viewModel: ChooseYourOwnAdventureViewModel, navigationBar: AppNavigationBar?) {
        
        self.viewModel = viewModel
        super.init(viewModel: viewModel, navigationBar: navigationBar)
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
    }
    
    override func setupLayout() {
        super.setupLayout()
                
        // pageNavigationView
        pageNavigationView.gestureScrollingEnabled = false
    }
    
    override func setupBinding() {
        super.setupBinding()
    }
    
    func languageTapped(index: Int) {
        viewModel.languageTapped(index: index)
    }
}
