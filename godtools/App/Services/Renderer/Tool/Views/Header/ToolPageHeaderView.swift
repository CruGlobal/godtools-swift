//
//  ToolPageHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 2/17/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class ToolPageHeaderView: MobileContentView {
    
    private var trainingTipView: TrainingTipView?
    
    let viewModel: ToolPageHeaderViewModelType
    
    @IBOutlet weak private var backgroundContainerView: UIView!
    @IBOutlet weak private var numberLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var trainingTipContainerView: UIView!
            
    required init(viewModel: ToolPageHeaderViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: ToolPageHeaderView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.backgroundColor = .clear
            rootNibView.frame = bounds
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    private func setupLayout() {
        
        // trainingTipContainerView
        trainingTipContainerView.backgroundColor = .clear
        trainingTipContainerView.isHidden = true
    }
    
    private func setupBinding() {
        
        semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        backgroundContainerView.backgroundColor = viewModel.backgroundColor
        
        numberLabel.text = viewModel.number
        numberLabel.font = viewModel.numberFont
        numberLabel.textColor = viewModel.numberColor
        numberLabel.textAlignment = viewModel.numberAlignment
        
        titleLabel.text = viewModel.title
        titleLabel.font = viewModel.titleFont
        titleLabel.textColor = viewModel.titleColor
        titleLabel.setLineSpacing(lineSpacing: 2)
        titleLabel.textAlignment = viewModel.titleAlignment
        
        if let trainingTipViewModel = viewModel.trainingTipViewModel {
            let trainingTipView = TrainingTipView(viewModel: trainingTipViewModel)
            setParentAndAddChild(childView: trainingTipView)
            trainingTipContainerView.addSubview(trainingTipView)
            trainingTipView.constrainEdgesToSuperview()
            trainingTipContainerView.isHidden = false
            self.trainingTipView = trainingTipView
        }
    }
    
    var titleLabelFrame: CGRect {
        return titleLabel.frame
    }
}
