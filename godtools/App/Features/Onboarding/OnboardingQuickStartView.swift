//
//  OnboardingQuickStartView.swift
//  godtools
//
//  Created by Robert Eldredge on 11/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingQuickStartView: UIViewController {
    
    enum DismissOnboardingTutorialType {
        case readArticles
        case tryLessons
        case chooseTool
    }
    
    private let viewModel: OnboardingQuickStartViewModelType
    
    private var skipButton: UIBarButtonItem?
    
    weak var delegate: OnboardingQuickStartCellDelegate?
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var endTutorialButton: OnboardPrimaryButton!
    @IBOutlet weak private var quickStartTableView: UITableView!
    
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
        
        titleLabel.text = viewModel.title
        
        endTutorialButton.setTitle(viewModel.endTutorialButtonTitle, for: .normal)
        
        setSkipButton()
        
        quickStartTableView.register(
            UINib(nibName: OnboardingQuickStartCell.nibName, bundle: nil),
            forCellReuseIdentifier: OnboardingQuickStartCell.reuseIdentifier
        )
        
        quickStartTableView.separatorStyle = .none
        quickStartTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setupBinding() {
        
    }
    
    private func reloadData() {
        
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

// MARK: - OnboardingQuickStartCellDelegate

extension OnboardingQuickStartView: OnboardingQuickStartCellDelegate {
    
    func buttonTapped(flowStep: FlowStep) {
        
        viewModel.quickStartCellLinkButtonTapped(flowStep: flowStep)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension OnboardingQuickStartView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.quickStartItemCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: OnboardingQuickStartCell = quickStartTableView.dequeueReusableCell(
            withIdentifier: OnboardingQuickStartCell.reuseIdentifier,
            for: indexPath) as! OnboardingQuickStartCell
                
        let quickStartItem = viewModel.quickStartCellWillAppear(index: indexPath.row)
        cell.configure(item: quickStartItem, delegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = view.backgroundColor
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }
}
