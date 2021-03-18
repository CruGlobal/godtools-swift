//
//  ToolPageCallToActionView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCallToActionViewDelegate: class {
    func callToActionNextButtonTapped()
}

class ToolPageCallToActionView: UIView {
    
    private weak var delegate: ToolPageCallToActionViewDelegate?
    
    let viewModel: ToolPageCallToActionViewModelType
        
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var nextButton: UIButton!
    
    required init(viewModel: ToolPageCallToActionViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
        
        nextButton.addTarget(self, action: #selector(handleNextTapped(button:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: ToolPageCallToActionView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.backgroundColor = .clear
            rootNibView.frame = bounds
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        
        titleLabel.text = viewModel.title
        titleLabel.textColor = viewModel.titleColor
        
        nextButton.semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        nextButton.setImage(viewModel.nextButtonImage, for: .normal)
        nextButton.setImageColor(color: viewModel.nextButtonColor)
    }
    
    @objc func handleNextTapped(button: UIButton) {
        delegate?.callToActionNextButtonTapped()
    }
    
    func configure(delegate: ToolPageCallToActionViewDelegate) {
        
        self.delegate = delegate
    }
}
