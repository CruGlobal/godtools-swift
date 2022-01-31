//
//  ChooseYourOwnAdventureView.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class ChooseYourOwnAdventureView: MobileContentPagesView {
    
    private let viewModel: ChooseYourOwnAdventureViewModelType
    
    private var navBarView: ChooseYourOwnAdventureNavBarView?
    
    required init(viewModel: ChooseYourOwnAdventureViewModelType) {
        
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: MobileContentPagesViewModelType) {
        fatalError("init(viewModel:) has not been implemented")
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
        
        navBarView = ChooseYourOwnAdventureNavBarView(
            languageTitles: viewModel.getNavBarLanguageTitles(),
            parentViewController: self,
            delegate: self
        )
        
        pageNavigationView.gestureScrollingEnabled = false
    }
}

// MARK: - ChooseYourOwnAdventureNavBarViewDelegate

extension ChooseYourOwnAdventureView: ChooseYourOwnAdventureNavBarViewDelegate {
    
    func chooseYourOwnAdventureNavBarBackTapped(navBar: ChooseYourOwnAdventureNavBarView) {

        pageNavigationView.scrollToPreviousPage(animated: true)
        
        viewModel.navBackTapped()
    }
    
    func chooseYourOwnAdventureLanguageSelectorTapped(navBar: ChooseYourOwnAdventureNavBarView, index: Int) {

        viewModel.languageTapped(index: index)
    }
}
