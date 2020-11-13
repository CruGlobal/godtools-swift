//
//  TrainingTipView.swift
//  godtools
//
//  Created by Levi Eggert on 11/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TrainingTipView: UIView {
    
    private let viewModel: TrainingTipViewModelType
    private let viewType: TrainingTipViewType
    
    @IBOutlet weak private var tipButton: UIButton!
    
    required init(viewModel: TrainingTipViewModelType, viewType: TrainingTipViewType) {
        
        self.viewModel = viewModel
        self.viewType = viewType
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        initializeNib()
        setupLayout()
        setupBinding()
        
        tipButton.addTarget(self, action: #selector(handleTip(button:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
        
        //tipIconImageView.image = viewModel.tipImage
    }
    
    @objc func handleTip(button: UIButton) {
        viewModel.tipTapped()
    }
}
