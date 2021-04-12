//
//  LessonListItemView.swift
//  godtools
//
//  Created by Levi Eggert on 4/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonListItemView: UITableViewCell {
    
    static let nibName: String = "LessonListItemView"
    static let reuseIdentifier: String = "LessonListItemViewReuseIdentifier"
    
    private let lessonCornerRadius: CGFloat = 12
    
    private var viewModel: LessonListItemViewModelType?
    
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var lessonContentView: UIView!
    @IBOutlet weak private var topImageView: UIImageView!
    @IBOutlet weak private var bottomContentView: UIView!
    @IBOutlet weak private var topLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
        topImageView.image = nil
        topLabel.text = ""
    }
    
    private func setupLayout() {
        
        // shadowView
        shadowView.layer.cornerRadius = lessonCornerRadius
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.3
        shadowView.clipsToBounds = false
        contentView.clipsToBounds = false
        clipsToBounds = false
        
        // lessonContentView
        lessonContentView.layer.cornerRadius = lessonCornerRadius
        lessonContentView.clipsToBounds = true
        
        // topImageView
        topImageView.contentMode = .scaleAspectFill
        
        // bottomContentView
        bottomContentView.backgroundColor = .clear
    }
    
    func configure(viewModel: LessonListItemViewModelType) {
        
        self.viewModel = viewModel
        
        selectionStyle = .none
    }
}
