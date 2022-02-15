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
    
    private var backButtonItem: UIBarButtonItem?
    private var languageSelector: NavBarSelectorView?
    
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
        
        // navigation bar
        backButtonItem = addDefaultNavBackItem(target: self, action: #selector(backTapped))
        
        // languageSelector
        languageSelector = NavBarSelectorView(
            selectorButtonTitles: viewModel.getNavBarLanguageTitles(),
            selectedColor: viewModel.navBarColors.value.languageToggleSelectedColor,
            deselectedColor: viewModel.navBarColors.value.languageToggleDeselectedColor,
            delegate: self
        )
        
        navigationItem.titleView = languageSelector
        
        // pageNavigationView
        pageNavigationView.gestureScrollingEnabled = false
    }
    
    override func setupBinding() {
        super.setupBinding()
        
        viewModel.backButtonImage.addObserver(self) { [weak self] (image: UIImage?) in
            self?.backButtonItem?.image = image
        }
        
        viewModel.navBarColors.addObserver(self) { [weak self] (navBarModel: ChooseYourOwnAdventureNavBarModel) in
            
            self?.navigationController?.navigationBar.setupNavigationBarAppearance(
                backgroundColor: navBarModel.barColor,
                controlColor: navBarModel.controlColor,
                titleFont: nil,
                titleColor: nil,
                isTranslucent: false
            )
            
            self?.languageSelector?.setSelectedColor(
                selectedColor: navBarModel.languageToggleSelectedColor,
                deselectedColor: navBarModel.languageToggleDeselectedColor
            )
            self?.languageSelector?.layer.borderColor = navBarModel.languageToggleBorderColor.cgColor
            
            self?.navigationController?.navigationBar.setNeedsLayout()
        }
    }
    
    @objc private func backTapped() {
        
        pageNavigationView.scrollToPreviousPage(animated: true)
        
        viewModel.navBackTapped()
    }
}

// MARK: - NavBarSelectorViewDelegate

extension ChooseYourOwnAdventureView: NavBarSelectorViewDelegate {
    func navBarSelectorTapped(navBarSelector: NavBarSelectorView, index: Int) {
        viewModel.navLanguageTapped(index: index)
    }
}
