//
//  PrimaryEvaluationOptionButton.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

@IBDesignable
class PrimaryEvaluationOptionButton: UIButton {
    
    private var didPrepareForInterfaceBuilder: Bool = false
    
    @IBInspectable var primaryColor: UIColor = UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1) {
        didSet {
            if didPrepareForInterfaceBuilder {
                setupLayout()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        
        setupLayout()
    }
    
    private func setupLayout() {
        
        if let font = FontLibrary.sfProTextRegular.font(size: 17) {
            titleLabel?.font = font
        }

        backgroundColor = .white
        layer.borderWidth = 1
        layer.cornerRadius = 28
        layer.borderColor = primaryColor.cgColor
        setTitleColor(primaryColor, for: .normal)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        didPrepareForInterfaceBuilder = true
        setupLayout()
    }
}
