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
    
    private let deSelectedColor: UIColor = .white
    
    private var didPrepareForInterfaceBuilder: Bool = false
    
    private(set) var optionState: PrimaryEvaluationOptionState = .deSelected
    
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
        setOptionState(optionState: .deSelected)
    }
    
    private func setupLayout() {
        
        if let font = FontLibrary.sfProTextRegular.uiFont(size: 17) {
            titleLabel?.font = font
        }

        backgroundColor = deSelectedColor
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
    
    func setOptionState(optionState: PrimaryEvaluationOptionState) {
        
        let backgroundColor: UIColor
        let titleColor: UIColor
        
        switch optionState {
        
        case .deSelected:
            backgroundColor = deSelectedColor
            titleColor = primaryColor
        
        case .selected:
            backgroundColor = primaryColor
            titleColor = deSelectedColor
        }
        
        self.backgroundColor = backgroundColor
        setTitleColor(titleColor, for: .normal)
    }
}
