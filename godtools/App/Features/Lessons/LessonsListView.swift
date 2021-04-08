//
//  LessonsListView.swift
//  godtools
//
//  Created by Levi Eggert on 4/5/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonsListView: UIViewController {
    
    private let viewModel: LessonsListViewModelType
            
    required init(viewModel: LessonsListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LessonsListView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
        
        setupLayout()
        setupBinding()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
    
    func scrollToTopOfLessons(animated: Bool) {
        // TODO: Implement. ~Levi
        //tableView.setContentOffset(.zero, animated: animated)
    }
}
