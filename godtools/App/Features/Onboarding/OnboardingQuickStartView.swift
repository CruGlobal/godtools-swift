//
//  OnboardingQuickStartView.swift
//  godtools
//
//  Created by Robert Eldredge on 11/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingQuickStartView: UIViewController {
    
    private let viewModel: OnboardingQuickStartViewModelType
    
    private var skipButton: UIBarButtonItem?
        
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var quickStartTableView: UITableView!
    @IBOutlet weak private var bottomGradientView: UIView!
    @IBOutlet weak private var endTutorialButton: OnboardPrimaryButton!
    
    required init(viewModel: OnboardingQuickStartViewModelType) {
        
        self.viewModel = viewModel

        super.init(nibName: String(describing: OnboardingQuickStartView.self), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        
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
        
        endTutorialButton.addTarget(self, action: #selector(handleEndTutorial), for: .touchUpInside)
        
        quickStartTableView.delegate = self
        quickStartTableView.dataSource = self
    }
    
    private func setupLayout() {
        
        // skipButton
        setSkipButton()
        
        // quickStartTableView
        quickStartTableView.register(
            UINib(nibName: OnboardingQuickStartCell.nibName, bundle: nil),
            forCellReuseIdentifier: OnboardingQuickStartCell.reuseIdentifier
        )
        
        quickStartTableView.showsVerticalScrollIndicator = false
        
        quickStartTableView.separatorStyle = .none
        quickStartTableView.rowHeight = UITableView.automaticDimension
        
        // bottomGradientView
        bottomGradientView.layoutIfNeeded()
        bottomGradientView.backgroundColor = .clear
        bottomGradientView.isUserInteractionEnabled = false
        let gradient = CAGradientLayer()
        gradient.frame = bottomGradientView.bounds
        gradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.85).cgColor,
            UIColor.white.withAlphaComponent(1).cgColor
        ]
        gradient.locations = [
            0,
            0.25,
            1
        ]
        bottomGradientView.layer.insertSublayer(gradient, at: 0)
        var quickStartContentInsetsForBottomGradient: UIEdgeInsets = quickStartTableView.contentInset
        quickStartContentInsetsForBottomGradient.bottom = bottomGradientView.bounds.size.height
        quickStartTableView.contentInset = quickStartContentInsetsForBottomGradient
    }
    
    private func setupBinding() {
        
        titleLabel.text = viewModel.title
        
        endTutorialButton.setTitle(viewModel.endTutorialButtonTitle, for: .normal)
    }
    
    private func setSkipButton() {
        
        let skipButtonPosition: ButtonItemPosition = .right
        
        if skipButton == nil {
            skipButton = addBarButtonItem(
                to: skipButtonPosition,
                title: viewModel.skipButtonTitle,
                style: .plain,
                color: UIColor(red: 0.231, green: 0.643, blue: 0.859, alpha: 1),
                target: self,
                action: #selector(handleSkip(barButtonItem:))
            )
        }
        else if let skipButton = skipButton {
            addBarButtonItem(item: skipButton, barPosition: skipButtonPosition)
        }
    }
    
    @objc func handleSkip(barButtonItem: UIBarButtonItem) {
        
        viewModel.skipButtonTapped()
    }
    
    @objc func handleEndTutorial() {
        
        viewModel.endTutorialButtonTapped()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension OnboardingQuickStartView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.quickStartItemCount
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.quickStartCellTapped(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: OnboardingQuickStartCell = quickStartTableView.dequeueReusableCell(
            withIdentifier: OnboardingQuickStartCell.reuseIdentifier,
            for: indexPath) as! OnboardingQuickStartCell
                
        let quickStartItem = viewModel.quickStartCellWillAppear(index: indexPath.row)
        cell.configure(item: quickStartItem)
        
        return cell
    }
}

