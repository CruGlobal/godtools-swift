//
//  OnboardingWelcomeView.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class OnboardingWelcomeView: UIViewController {
    
    private let viewModel: OnboardingWelcomeViewModelType
    
    @IBOutlet weak private var logoImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var beginButton: UIButton!
    
    required init(viewModel: OnboardingWelcomeViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "OnboardingWelcomeView", bundle: nil)
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
        
        beginButton.addTarget(self, action: #selector(handleBegin(button:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
    }
    
    private func setupLayout() {
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
    }
    
    private func setupBinding() {
        
        viewModel.logo.addObserver(self) { [weak self] (image: UIImage?) in
            self?.logoImageView.image = image
        }
        
        viewModel.title.addObserver(self) { [weak self] (title: String) in
            self?.titleLabel.text = title
        }
        
        viewModel.beginTitle.addObserver(self) { [weak self] (title: String) in
            self?.beginButton.setTitle(title, for: .normal)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateWelcomeToTagline()
    }
    
    private func animateWelcomeToTagline() {
        UIView.animate(withDuration: 0.25, delay: 0.75, options: .curveEaseOut, animations: { [weak self] in
            self?.titleLabel.alpha = 0
        }) { [weak self] (finished: Bool) in
            UIView.animate(withDuration: 0.15, delay: 0.25, options: .curveEaseOut, animations: { [weak self] in
                self?.viewModel.changeTitleToTagline()
                self?.titleLabel.alpha = 1
            }, completion: nil)
        }
    }
    
    @objc func handleBegin(button: UIButton) {
        viewModel.beginTapped()
    }
}
