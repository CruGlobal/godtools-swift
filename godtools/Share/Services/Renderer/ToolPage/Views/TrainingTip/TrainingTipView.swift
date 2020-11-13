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
    
    @IBOutlet weak private var tipIconImageView: UIImageView!
    @IBOutlet weak private var tipButton: UIButton!
    
    required init(viewModel: TrainingTipViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
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
        
        let nib: UINib = UINib(nibName: String(describing: TrainingTipView.self), bundle: nil)
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
        
        tipIconImageView.image = viewModel.tipImage
    }
}
