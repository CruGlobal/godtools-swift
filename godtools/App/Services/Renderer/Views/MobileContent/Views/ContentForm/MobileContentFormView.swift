//
//  MobileContentFormView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentFormView: MobileContentStackView {
    
    private let viewModel: MobileContentFormViewModel
    
    private var inputViews: [MobileContentInputView] = Array()
    private var currentEditedTextField: UITextField?
            
    @IBOutlet weak private var contentContainerView: UIView!
    
    init(viewModel: MobileContentFormViewModel) {
        
        self.viewModel = viewModel
            
        super.init(viewModel: viewModel, contentInsets: nil, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
    
    func getInputModels() -> [MobileContentFormInputModel] {
            
        var inputModels: [MobileContentFormInputModel] = Array()
        
        for inputView in inputViews {

            if let name = inputView.viewModel.getInputName() {
                
                let value: String = inputView.viewModel.getInputValue() ?? ""
                
                let inputModel = MobileContentFormInputModel(
                    name: name,
                    value: value,
                    isRequired: inputView.viewModel.isRequired
                )
                
                inputModels.append(inputModel)
            }
        }
        
        return inputModels
    }
    
    func resignCurrentEditedTextField() {
        currentEditedTextField?.resignFirstResponder()
        currentEditedTextField = nil
    }
    
    private func getVisibleInputTextFields() -> [UITextField] {
        return inputViews.compactMap({
            guard !$0.isHiddenInput else {
                return nil
            }
            return $0.getInputTextField()
        })
    }
    
    // MARK: - MobileContentView

    override func renderChild(childView: MobileContentView) {
        
        if let inputView = childView as? MobileContentInputView {
            
            inputViews.append(inputView)
            
            if inputView.viewModel.isHidden {
                return
            }
            else {
                inputView.setInputDelegate(delegate: self)
            }
        }
        
        super.renderChild(childView: childView)
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}

// MARK: - UITextFieldDelegate

extension MobileContentFormView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        currentEditedTextField = textField
        
        let inputTextFields: [UITextField] = getVisibleInputTextFields()
        let isLastInput: Bool = textField == inputTextFields.last
        
        textField.returnKeyType = !isLastInput ? .next : .done
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentEditedTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let inputTextFields: [UITextField] = getVisibleInputTextFields()
        
        if let textInputIndex = inputTextFields.firstIndex(of: textField) {
            
            let nextTextInputIndex: Int = textInputIndex + 1
            
            if nextTextInputIndex >= inputTextFields.count {
                textField.resignFirstResponder()
            }
            else {
                inputTextFields[nextTextInputIndex].becomeFirstResponder()
            }
        }

        return true
    }
}
