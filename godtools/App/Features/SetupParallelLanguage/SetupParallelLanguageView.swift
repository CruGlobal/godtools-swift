//
//  SetupParallelLanguageView.swift
//  godtools
//
//  Created by Robert Eldredge on 11/19/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import Lottie
import UIKit

class SetupParallelLanguageView: UIViewController {
    
    private let viewModel: SetupParallelLanguageViewModelType
    
    private var skipButton: UIBarButtonItem?
    
    @IBOutlet weak private var animationView: AnimationView!
    @IBOutlet weak private var bodyLabel: UILabel!
    @IBOutlet weak private var languagePicker: UIPickerView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var selectLanguageButton: UIButton!
    @IBOutlet weak private var getStartedButton: UIButton!

    required init(viewModel: SetupParallelLanguageViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(nibName: String(describing: SetupParallelLanguageView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}
