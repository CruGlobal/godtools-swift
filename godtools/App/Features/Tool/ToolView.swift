//
//  ToolView.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolView: MobileContentPagesView {
    
    private let viewModel: ToolViewModel
    private let navBarView: ToolNavBarView = ToolNavBarView()
                    
    required init(viewModel: ToolViewModel) {
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
    }
    
    override func setupBinding() {
        super.setupBinding()
        
        navBarView.configure(
            parentViewController: self,
            viewModel: viewModel.navBarViewModel,
            delegate: self
        )
    }
}

// MARK: - ToolNavBarViewDelegate

extension ToolView: ToolNavBarViewDelegate {
    
    func navBarHomeTapped(navBar: ToolNavBarView, remoteShareIsActive: Bool) {
        viewModel.navHomeTapped(remoteShareIsActive: remoteShareIsActive)
    }
    
    func navBarShareTapped(navBar: ToolNavBarView, selectedLanguage: LanguageModel) {
        viewModel.navShareTapped(selectedLanguage: selectedLanguage)
    }
    
    func navBarLanguageChanged(navBar: ToolNavBarView) {
        viewModel.navLanguageChanged()
    }
}
