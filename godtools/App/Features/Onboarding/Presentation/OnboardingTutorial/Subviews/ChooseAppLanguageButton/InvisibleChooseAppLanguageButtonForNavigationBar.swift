//
//  InvisibleChooseAppLanguageButtonForNavigationBar.swift
//  godtools
//
//  Created by Levi Eggert on 10/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class InvisibleChooseAppLanguageButtonForNavigationBar: UIView {
    
    private let width: CGFloat = ChooseAppLanguageButton.width
    private let height: CGFloat = ChooseAppLanguageButton.height
    private let tappedClosure: (() -> Void)?
        
    init(showForDebugging: Bool = false, tappedClosure: (() -> Void)?) {
        
        self.tappedClosure = tappedClosure
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
                        
        let button = UIButton(type: .custom)
        
        button.frame = bounds
        button.backgroundColor = showForDebugging ? UIColor.red.withAlphaComponent(0.3) : .clear
        addSubview(button)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = AccessibilityStrings.Button.chooseAppLanguage.id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonTapped() {
        tappedClosure?()
    }
}
