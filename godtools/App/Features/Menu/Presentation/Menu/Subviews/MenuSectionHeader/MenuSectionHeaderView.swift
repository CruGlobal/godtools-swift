//
//  MenuSectionHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 7/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MenuSectionHeaderView: UIView, NibBased {
     
    private let viewModel: MenuSectionHeaderViewModel
    
    @IBOutlet weak private var headerLabel: UILabel!
    
    required init(size: CGSize, viewModel: MenuSectionHeaderViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        initialize()
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        
        loadNib()
        
        setupLayout()
        setupBinding()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        headerLabel.text = viewModel.headerTitle
    }
}
