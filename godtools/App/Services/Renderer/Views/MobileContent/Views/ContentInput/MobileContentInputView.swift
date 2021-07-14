//
//  MobileContentInputView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentInputView: MobileContentView {
    
    let viewModel: MobileContentInputViewModelType
        
    @IBOutlet weak private var inputLabel: UILabel!
    @IBOutlet weak private var inputTextField: UITextField!
    
    required init(viewModel: MobileContentInputViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
        
        inputTextField.addTarget(self, action: #selector(handleInputChanged(textField:)), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: MobileContentInputView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToSuperview()
        }
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

    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
}
