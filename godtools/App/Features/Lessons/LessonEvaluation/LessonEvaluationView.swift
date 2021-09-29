//
//  LessonEvaluationView.swift
//  godtools
//
//  Created by Levi Eggert on 9/29/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LessonEvaluationView: UIViewController {
    
    private let viewModel: LessonEvaluationViewModelType
            
    required init(viewModel: LessonEvaluationViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: LessonEvaluationView.self), bundle: nil)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
