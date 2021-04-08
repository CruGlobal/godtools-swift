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
    
    private var viewModel: LessonListItemViewModelType?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
    
    func configure(viewModel: LessonListItemViewModelType) {
        
        self.viewModel = viewModel
        
        selectionStyle = .none
    }
}
