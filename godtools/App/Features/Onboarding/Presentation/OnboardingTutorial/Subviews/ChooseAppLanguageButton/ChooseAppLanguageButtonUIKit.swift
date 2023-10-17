//
//  ChooseAppLanguageButtonUIKit.swift
//  godtools
//
//  Created by Levi Eggert on 10/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit
import SwiftUI

class ChooseAppLanguageButtonUIKit: UIView {
    
    private let color: UIColor = Color.getUIColorWithRGB(red: 238, green: 236, blue: 238, opacity: 1)
    private let cornerRadius: CGFloat = 22
    private let width: CGFloat = 175
    private let height: CGFloat = 44
    private let title: String
    private let titleColor: UIColor = ColorPalette.gtGrey.uiColor
    private let titleFont: UIFont? = FontLibrary.sfProTextRegular.uiFont(size: 16)
    private let tappedClosure: (() -> Void)?
    
    init(title: String, tappedClosure: (() -> Void)?) {
        
        self.title = title
        self.tappedClosure = tappedClosure
        
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        _ = addWidthConstraint(constant: width)
        _ = addHeightConstraint(constant: height)
        
        backgroundColor = .clear
        
        let button = UIButton(type: .custom)
        button.frame = bounds
        button.backgroundColor = color
        button.layer.cornerRadius = cornerRadius
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = titleFont
        
        addSubview(button)
        button.constrainEdgesToView(view: self)
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonTapped() {
        tappedClosure?()
    }
}
