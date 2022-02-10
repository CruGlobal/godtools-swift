//
//  ChooseYourOwnAdventureNavBarView.swift
//  godtools
//
//  Created by Levi Eggert on 1/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

protocol ChooseYourOwnAdventureNavBarViewDelegate: AnyObject {
    
    func chooseYourOwnAdventureNavBarBackTapped(navBar: ChooseYourOwnAdventureNavBarView)
    func chooseYourOwnAdventureLanguageSelectorTapped(navBar: ChooseYourOwnAdventureNavBarView, index: Int)
}

class ChooseYourOwnAdventureNavBarView {
        
    private weak var parentViewController: UIViewController?
    private weak var delegate: ChooseYourOwnAdventureNavBarViewDelegate?
    
    private var languageSelector: NavBarSelectorView?
    
    required init(languageTitles: [String], parentViewController: UIViewController, delegate: ChooseYourOwnAdventureNavBarViewDelegate?) {
        
        self.parentViewController = parentViewController
        self.delegate = delegate
        
        setupLayout(languageTitles: languageTitles)
    }
    
    private func setupLayout(languageTitles: [String]) {
        
        _ = parentViewController?.addDefaultNavBackItem(target: self, action: #selector(backTapped))
        
        // languageSelector
        languageSelector = NavBarSelectorView(
            selectorButtonTitles: languageTitles,
            selectedColor: ColorPalette.gtBlue.color,
            deselectedColor: .white,
            delegate: self
        )
        languageSelector?.layer.borderColor = ColorPalette.gtBlue.color.cgColor
        parentViewController?.navigationItem.titleView = languageSelector
    }
    
    @objc private func backTapped() {
        
        delegate?.chooseYourOwnAdventureNavBarBackTapped(navBar: self)
    }
}

// MARK: - NavBarSelectorViewDelegate

extension ChooseYourOwnAdventureNavBarView: NavBarSelectorViewDelegate {
    
    func navBarSelectorTapped(navBarSelector: NavBarSelectorView, index: Int) {
        
        delegate?.chooseYourOwnAdventureLanguageSelectorTapped(navBar: self, index: index)
    }
}
