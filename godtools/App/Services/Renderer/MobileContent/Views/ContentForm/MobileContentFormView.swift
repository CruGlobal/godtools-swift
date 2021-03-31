//
//  MobileContentFormView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentFormView: MobileContentStackView {
    
    private let viewModel: MobileContentFormViewModelType
    
    private var inputViews: [MobileContentInputView] = Array()
    private var currentEditedTextField: UITextField?
            
    @IBOutlet weak private var contentContainerView: UIView!
    
    required init(viewModel: MobileContentFormViewModelType) {
        
        self.viewModel = viewModel
            
        super.init(itemSpacing: 15, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()        
    }
    
    required init(itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemSpacing:scrollIsEnabled:) has not been implemented")
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
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
    
    // MARK: -
}

// MARK: - UITextFieldDelegate

extension MobileContentFormView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentEditedTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentEditedTextField = textField
    }
}
