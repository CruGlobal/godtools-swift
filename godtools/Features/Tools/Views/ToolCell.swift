//
//  ToolCell.swift
//  godtools
//
//  Created by Levi Eggert on 5/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolCell: UITableViewCell {
    
    static let nibName: String = "ToolCell"
    static let reuseIdentifier: String = "ToolCellReuseIdentifier"
    
    private let toolCornerRadius: CGFloat = 12
    
    private var viewModel: ToolCellViewModelType?
    
    @IBOutlet weak private var toolShadowView: UIView!
    @IBOutlet weak private var toolContentView: UIView!
    @IBOutlet weak private var bannerImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var parallelLanguageLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var aboutToolButton: UIButton!
    @IBOutlet weak private var openToolButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    private func setupLayout() {
        
        // toolShadowView
        toolShadowView.layer.cornerRadius = toolCornerRadius
        toolShadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        toolShadowView.layer.shadowColor = UIColor.black.cgColor
        toolShadowView.layer.shadowRadius = 3
        toolShadowView.layer.shadowOpacity = 0.3
        toolShadowView.clipsToBounds = false
        contentView.clipsToBounds = false
        clipsToBounds = false
        
        // toolContentView
        toolContentView.layer.cornerRadius = toolCornerRadius
        toolContentView.clipsToBounds = true
        
        // bannerImageView
        bannerImageView.contentMode = .scaleAspectFill
        
        // about and open buttons
        let buttonCornerRadius: CGFloat = 6
        aboutToolButton.layer.cornerRadius = buttonCornerRadius
        aboutToolButton.layer.borderWidth = 1
        aboutToolButton.layer.borderColor = aboutToolButton.titleColor(for: .normal)?.cgColor
        openToolButton.layer.cornerRadius = buttonCornerRadius
    }
    
    func configure(viewModel: ToolCellViewModelType) {
        
        self.viewModel = viewModel
    }
}
