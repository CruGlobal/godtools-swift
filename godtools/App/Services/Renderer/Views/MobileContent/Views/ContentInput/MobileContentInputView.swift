//
//  MobileContentInputView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentInputView: MobileContentView, NibBased {
    
    let viewModel: MobileContentInputViewModelType
        
    @IBOutlet weak private var inputLabel: UILabel!
    @IBOutlet weak private var inputTextField: UITextField!
    
    required init(viewModel: MobileContentInputViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        loadNib()
        setupLayout()
        setupBinding()
        
        inputTextField.addTarget(self, action: #selector(handleInputChanged(textField:)), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        // inputLabel
        inputLabel.text = viewModel.inputLabel
        
        // inputTextField
        inputTextField.placeholder = viewModel.placeholder
    }
    
    @objc func handleInputChanged(textField: UITextField) {
        viewModel.inputChanged(text: textField.text)
    }
    
    func setInputDelegate(delegate: UITextFieldDelegate) {
        inputTextField.delegate = delegate
    }
    
    // MARK: - MobileContentView

    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
}
