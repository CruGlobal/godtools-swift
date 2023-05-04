//
//  MenuItemView.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MenuItemView: UITableViewCell {
    
    static let nibName: String = "MenuItemView"
    static let reuseIdentifier: String = "MenuItemViewReuseIdentifier"
      
    private var viewModel: MenuItemViewModel?
    
    @IBOutlet weak private var selectedView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var rightArrowImageView: UIImageView!
    @IBOutlet weak private var separatorLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedView.alpha = 0
        titleLabel.text = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        selectedView.alpha = 0
        titleLabel.text = nil
    }
    
    func configure(viewModel: MenuItemViewModel, hidesSeparator: Bool) {
        
        self.viewModel = viewModel
        
        selectionStyle = .none
        
        titleLabel.text = viewModel.title
        rightArrowImageView.isHidden = viewModel.selectionDisabled
        separatorLine.isHidden = hidesSeparator
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected, let viewModel = self.viewModel, !viewModel.selectionDisabled {
            playSelectedAnimation()
        }
    }
    
    private func playSelectedAnimation() {
        selectedView.alpha = 1
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: { [weak self] in
            self?.selectedView.alpha = 0
        }) { (finished: Bool) in
        }
    }
}
