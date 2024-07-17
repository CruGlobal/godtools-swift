//
//  TrainingTipView.swift
//  godtools
//
//  Created by Levi Eggert on 11/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TrainingTipView: MobileContentView, NibBased {
    
    private let viewModel: TrainingTipViewModel
    
    @IBOutlet weak private var tipButton: UIButton!
    @IBOutlet weak private var tipImage: UIImageView!
    
    init(viewModel: TrainingTipViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        loadNib()
        setupLayout()
        setupBinding()
        
        tipButton.addTarget(self, action: #selector(handleTip(button:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        viewModel.trainingTipBackgroundImage.addObserver(self) { [weak self] (backgroundImage: UIImage?) in
            self?.tipButton.setBackgroundImage(backgroundImage, for: .normal)
        }
        
        viewModel.trainingTipForegroundImage.addObserver(self) { [weak self] (foregroundImage: UIImage?) in
            self?.tipImage.image = foregroundImage
        }
    }
    
    @objc func handleTip(button: UIButton) {
        
        let event: TrainingTipEvent? = viewModel.tipTapped()
        
        if let event = event {
            super.sendTrainingTipTappedToRootView(event: event)
        }
    }
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        super.renderChild(childView: childView)
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .equalToSize(size: CGSize(width: 50, height: 50))
    }
    
    // MARK: - 
}
