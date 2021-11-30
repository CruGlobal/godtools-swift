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
    
    private var closeButton: UIBarButtonItem?

    @IBOutlet weak private var animatedView: AnimatedView!
    @IBOutlet weak private var promptLabel: UILabel!
    @IBOutlet weak private var selectLanguageButton: UIButton!
    //@IBOutlet weak private var languagePicker: UIPickerView!
    //@IBOutlet weak private var yesButton: UIButton!
    //@IBOutlet weak private var noButton: UIButton!
    //@IBOutlet weak private var selectLanguageButton: UIButton!
    //@IBOutlet weak private var getStartedButton: UIButton!

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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupLayout()
        
        animatedView.configure(viewModel: viewModel.animatedViewModel)
        
        promptLabel.text = viewModel.promptText
    }
    
    private func setupLayout() {
        
        closeButton = addBarButtonItem(
            to: .right,
            image: ImageCatalog.navClose.image,
            color: ColorPalette.gtBlue.color,
            target: self,
            action: #selector(handleClose)
        )
        
        selectLanguageButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        selectLanguageButton.layer.shadowOffset = CGSize(width: 2, height: 4)
        selectLanguageButton.layer.shadowOpacity = 1.0
        selectLanguageButton.layer.shadowRadius = 0.0
        selectLanguageButton.layer.masksToBounds = false
        selectLanguageButton.layer.cornerRadius = 6
    }
    
    @objc func handleClose(barButtonItem: UIBarButtonItem) {
        viewModel.closeButtonTapped()
    }
}
