//
//  MobileContentFormView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MobileContentFormView: UIView {
    
    private let viewModel: MobileContentFormViewModelType
    
    private var inputs: [MobileContentInputView] = Array()
    private var currentEditedTextField: UITextField?
            
    @IBOutlet weak private var contentContainerView: UIView!
    
    required init(viewModel: MobileContentFormViewModelType) {
        
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
        
        let nib: UINib = UINib(nibName: String(describing: MobileContentFormView.self), bundle: nil)
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
        
        let contentViewModel: ToolPageContentStackContainerViewModel = viewModel.contentViewModel
        
        contentViewModel.contentStackRenderer.didRenderContentInputSignal.addObserver(self) { [weak self] (renderedInput: ToolPageRenderedContentInput) in
            self?.handleDidRenderContentInput(contentInput: renderedInput.view)
        }
        
        // TODO: Fix this for new renderer changes. ~Levi
        /*
        let contentStackView = MobileContentStackView(viewRenderer: contentViewModel.contentStackRenderer, itemSpacing: 15, scrollIsEnabled: false)
        contentContainerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.constrainEdgesToSuperview()*/
    }
    
    private func handleDidRenderContentInput(contentInput: MobileContentInputView) {
        contentInput.setInputDelegate(delegate: self)
        inputs.append(contentInput)
    }
    
    func resignCurrentEditedTextField() {
        currentEditedTextField?.resignFirstResponder()
        currentEditedTextField = nil
    }
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
