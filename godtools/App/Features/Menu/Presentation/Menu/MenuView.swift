//
//  MenuView.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class MenuView: UIViewController {
    
    private let viewModel: MenuViewModel
    private let headerHeight: CGFloat = 44
    private let rowHeight: CGFloat = 50
    
    @IBOutlet weak var tableView: UITableView!
        
    var isComingFromLoginBanner = false
    
    required init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: MenuView.self), bundle: nil)
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
        setupBinding()
                        
        _ = addBarButtonItem(
            to: .right,
            title: viewModel.navDoneButtonTitle,
            style: .done,
            color: nil,
            target: self,
            action: #selector(handleDone(barButtonItem:))
        )
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLayout() {
                
        tableView.separatorStyle = .none
        tableView.rowHeight = rowHeight
        tableView.register(
            UINib(nibName: MenuItemView.nibName, bundle: nil),
            forCellReuseIdentifier: MenuItemView.reuseIdentifier
        )
    }
    
    private func setupBinding() {
        
        viewModel.navTitle.addObserver(self) { [weak self] (title: String) in
            self?.title = title
        }
        
        viewModel.menuDataSource.addObserver(self) { [weak self] (menuDataSource: MenuDataSource) in
            self?.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.pageViewed()
    }
    
    @objc func handleDone(barButtonItem: UIBarButtonItem) {
        viewModel.doneTapped()
    }
}

// MARK: - UITableViewDataSource

extension MenuView: UITableViewDataSource {
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.menuDataSource.value.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let menuDataSource: MenuDataSource = viewModel.menuDataSource.value
        let menuSection: MenuSection = menuDataSource.sections[section]
        
        return menuDataSource.items[menuSection]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: MenuItemView = tableView.dequeueReusableCell(
            withIdentifier: MenuItemView.reuseIdentifier,
            for: indexPath) as! MenuItemView
                        
        let numberOfRowsInSection: Int = tableView.numberOfRows(inSection: indexPath.section)
        let isLastRowOfSection: Bool = indexPath.row == numberOfRowsInSection - 1
        
        cell.configure(
            viewModel: viewModel.menuItemWillAppear(sectionIndex: indexPath.section, itemIndexRelativeToSection: indexPath.row),
            hidesSeparator: isLastRowOfSection
        )
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MenuView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
                
        let menuSectionHeader = MenuSectionHeaderView(
            size: CGSize(width: tableView.frame.size.width, height: headerHeight),
            viewModel: viewModel.menuSectionWillAppear(sectionIndex: section)
        )
                
        return menuSectionHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let menuItem: MenuItem = viewModel.menuDataSource.value.getMenuItem(at: indexPath)
        
        switch menuItem {
        
        case .tutorial:
            viewModel.tutorialTapped()
            
        case .languageSettings:
            viewModel.languageSettingsTapped()
            
        case .login:
            viewModel.loginTapped(fromViewController: self)
            
        case .activity:
            viewModel.activityTapped()
            
        case .createAccount:
            viewModel.createAccountTapped(fromViewController: self)
            
        case .logout:
            viewModel.logoutTapped(fromViewController: self)
            
        case .deleteAccount:
            viewModel.deleteAccountTapped()
            
        case .sendFeedback:
            viewModel.sendFeedbackTapped()
        
        case .reportABug:
            viewModel.reportABugTapped()
            
        case .askAQuestion:
            viewModel.askAQuestionTapped()
        
        case .leaveAReview:
            viewModel.leaveAReviewTapped()
            
        case .shareAStoryWithUs:
            viewModel.shareAStoryWithUsTapped()
        
        case .shareGodTools:
            viewModel.shareGodToolsTapped()
        
        case .termsOfUse:
            viewModel.termsOfUseTapped()
        
        case .privacyPolicy:
            viewModel.privacyPolicyTapped()
        
        case .copyrightInfo:
            viewModel.copyrightInfoTapped()
            
        case .version:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
}
