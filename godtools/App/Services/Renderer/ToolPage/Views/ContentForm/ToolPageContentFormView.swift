//
//  ToolPageContentFormView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentFormView: UIView {
    
    private let viewModel: ToolPageContentFormViewModelType
    
    private var inputs: [ToolPageContentInputView] = Array()
    private var currentEditedTextField: UITextField?
            
    @IBOutlet weak private var contentContainerView: UIView!
    
    required init(viewModel: ToolPageContentFormViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: ToolPageContentFormView.self), bundle: nil)
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
        
        viewModel.resignCurrentInputSignal.addObserver(self) { [weak self] in
            self?.resignCurrentEditedTextField()
        }
            
        // TODO: Need to add this back in. ~Levi
        /*
        viewModel.contentRenderer.didRenderContentInputSignal.addObserver(self) { [weak self] (renderedInput: ToolPageRenderedContentInput) in
            self?.handleDidRenderContentInput(contentInput: renderedInput.view)
        }*/
        
        viewModel.contentView.addObserver(self) { [weak self] (contentView: MobileContentStackView?) in
            if let contentView = contentView {
                self?.addContentView(contentView: contentView)
            }
        }
    }
    
    private func handleDidRenderContentInput(contentInput: ToolPageContentInputView) {
        contentInput.setInputDelegate(delegate: self)
        inputs.append(contentInput)
    }
    
    private func addContentView(contentView: MobileContentStackView) {
        contentContainerView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.constrainEdgesToSuperview()
    }
    
    func resignCurrentEditedTextField() {
        currentEditedTextField?.resignFirstResponder()
        currentEditedTextField = nil
    }
}

// MARK: - UITextFieldDelegate

extension ToolPageContentFormView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentEditedTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentEditedTextField = textField
    }
}
