//
//  MenuTableViewCell.swift
//  godtools
//
//  Created by Devserker on 4/25/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    
    static let nibName: String = "MenuCell"
    static let reuseIdentifier: String = "MenuCellReuseIdentifier"
      
    private var viewModel: MenuCellViewModel?
    
    @IBOutlet weak private var selectedView: UIView!
    @IBOutlet weak private var titleLabel: GTLabel!
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
    
    func configure(viewModel: MenuCellViewModel) {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        rightArrowImageView.isHidden = viewModel.selectionDisabled
        separatorLine.isHidden = viewModel.hidesSeparator
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
