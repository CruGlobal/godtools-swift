//
//  TutorialFlow.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

enum TutorialFlowStep: FlowStep {

}

class TutorialFlow: NSObject {
    
    let navigationController: UINavigationController
    
    deinit {
        print("x deinit: \(type(of: self))\n")
    }
    
    override init() {
        print("init: \(type(of: self))\n")
        
        self.navigationController = UINavigationController(nibName: nil, bundle: nil)
        
        super.init()
        
        navigationController.navigationBar.barTintColor = UIColor.white
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.setNavigationBarHidden(false, animated: false)
        
        let viewModel = TutorialViewModel(flowDelegate: self, tutorialItemsProvider: TutorialItemProvider())
        let view = TutorialView(viewModel: viewModel)
        navigationController.setViewControllers([view], animated: false)
    }
}

extension TutorialFlow: FlowDelegate {
    
    func navigate(step: FlowStep) {
        
        guard let tutorialFlowStep = step as? TutorialFlowStep else {
            return
        }
        
        switch tutorialFlowStep {
            
        }
    }
}
