//
//  TrainingTipView.swift
//  godtools
//
//  Created by Levi Eggert on 11/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TrainingTipView: MobileContentView {
    
    private let viewModel: TrainingTipViewModelType
    
    @IBOutlet weak private var tipButton: UIButton!
    @IBOutlet weak private var tipImage: UIImageView!
    
    required init(viewModel: TrainingTipViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        initializeNib()
        setupLayout()
        setupBinding()
        
        tipButton.addTarget(self, action: #selector(handleTip(button:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: TrainingTipView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToSuperview()
            rootNibView.backgroundColor = .clear
        }
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
        viewModel.tipTapped()
    }
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        super.renderChild(childView: childView)
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .equalToSize(size: CGSize(width: 50, height: 50))
    }
    
    // MARK: - 
}
