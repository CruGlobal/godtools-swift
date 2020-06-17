//
//  MenuView.swift
//  godtools
//
//  Created by Devserker on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import TheKeyOAuthSwift
import GTMAppAuth

/*
 ----The OAuth client ID.----
 For client configuration instructions, see the [README](h ttps://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 Set to nil to use dynamic registration with this example.
 
let kClientID: String? = "2880599195946831054";
  Testing Client_ID 2880599195946831054
  Real Client_ID 5337397229970887848

----The OAuth redirect URI for the client @c kClientID.----
 For client configuration instructions, see the [README](h ttps://github.com/openid/AppAuth-iOS/blob/master/Examples/Example-iOS_Swift-Carthage/README.md).
 
let kRedirectURI: String = "ppoauthapp://h ttps://stage.godtoolsapp.com/auth";
  Testing RedirectURI ppoauthapp://https://stage.godtoolsapp.com/auth
  Real RedirectURI //https://godtoolsapp.com/auth

 ----NSCoding key for the authState property.----
let kAppAuthExampleAuthStateKey: String = "authState";
  */


class MenuView: UIViewController {
    
    private let viewModel: MenuViewModelType
    private let headerHeight: CGFloat = 40.0
    private let rowHeight: CGFloat = 50
    
    @IBOutlet weak var tableView: UITableView!
        
    var isComingFromLoginBanner = false
    
    required init(viewModel: MenuViewModelType) {
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
        
        viewModel.loginClient.addStateChangeDelegate(delegate: self)
                
        _ = addBarButtonItem(
            to: .right,
            title: viewModel.navDoneButtonTitle,
            style: .done,
            color: nil,
            target: self,
            action: #selector(handleDone(barButtonItem:))
        )
    }
    
    private func setupLayout() {
        
        view.backgroundColor = .clear
        
        tableView.backgroundColor = .gtGreyLight
        tableView.separatorStyle = .none
        tableView.rowHeight = rowHeight
        tableView.register(
            UINib(nibName: MenuCell.nibName, bundle: nil),
            forCellReuseIdentifier: MenuCell.reuseIdentifier
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pageViewed()
        viewModel.reloadMenuDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isComingFromLoginBanner {
            openLoginWindow()
            isComingFromLoginBanner = false
        }
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
        
        return menuDataSource.items[menuSection.id]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: MenuCell = tableView.dequeueReusableCell(
            withIdentifier: MenuCell.reuseIdentifier,
            for: indexPath) as! MenuCell
                
        cell.selectionStyle = .none
                
        let menuItem: MenuItem = viewModel.menuDataSource.value.getMenuItem(at: indexPath)
        
        let selectionDisabled: Bool = menuItem.id == .version
        let numberOfRowsInSection: Int = tableView.numberOfRows(inSection: indexPath.section)
        let isLastRowOfSection: Bool = indexPath.row == numberOfRowsInSection - 1
        
        cell.configure(
            viewModel: MenuCellViewModel(
                menuItem: menuItem,
                selectionDisabled: selectionDisabled,
                hidesSeparator: isLastRowOfSection
        ))
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MenuView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let section: MenuSection = viewModel.menuDataSource.value.sections[section]
        let headerFrame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: headerHeight)
        let headerView:UIView = UIView(frame: headerFrame)
        headerView.backgroundColor = .gtGreyLight
        
        let labelFrame = CGRect(x: 20.0, y: 12.0, width: 100.0, height: 16.0)
        let titleLabel:GTLabel = GTLabel(frame: labelFrame)
        titleLabel.gtStyle = "blackTextSmall"
        titleLabel.text = section.title.uppercased()
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let menuItem: MenuItem = viewModel.menuDataSource.value.getMenuItem(at: indexPath)
        
        switch menuItem.id {
            
        case .languageSettings:
            viewModel.languageSettingsTapped()
        
        case .about:
            viewModel.aboutTapped()
        
        case .help:
            viewModel.helpTapped()
        
        case .contactUs:
            viewModel.contactUsTapped()
        
        case .logout:
            DispatchQueue.main.async { [weak self] in
                self?.presentLogoutConfirmation()
            }
            
        case .login:
            initiateLogin()
        
        case .createAccount:
            initiateLogin(additionalParameters: ["action":"signup"])
            
        case .myAccount:
            viewModel.myAccountTapped()
        
        case .shareGodTools:
            viewModel.shareGodToolsTapped()
        
        case .shareAStoryWithUs:
            viewModel.shareAStoryWithUsTapped()
        
        case .termsOfUse:
            viewModel.termsOfUseTapped()
        
        case .privacyPolicy:
            viewModel.privacyPolicyTapped()
        
        case .copyrightInfo:
            viewModel.copyrightInfoTapped()
            
        case .tutorial:
            viewModel.tutorialTapped()
            
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

// MARK: -

extension MenuView {
    
    fileprivate func initiateLogin(additionalParameters: [String: String]? = nil) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        delegate.currentAuthorizationFlow = viewModel.loginClient.initiateAuthorization(requestingViewController: self, additionalParameters: additionalParameters, callback: { (_) in
            // block unused
        })
    }
    
    fileprivate func presentLogoutConfirmation() {
       
        let dialogMessage = UIAlertController(title: "Proceed with GodTools logout?".localized, message: "You are about to logout of your GodTools account".localized, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { [weak self] (_) in

            self?.viewModel.loginClient.logout()
            self?.viewModel.reloadMenuDataSource()
        })
        
        let cancel = UIAlertAction(title: "cancel".localized, style: .cancel) { (_) in }
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        present(dialogMessage, animated: true, completion: nil)
    }
    
    fileprivate func openLoginWindow() {
        if viewModel.loginClient.isAuthenticated() {
            DispatchQueue.main.async {
                self.presentLogoutConfirmation()
            }
        } else {
            initiateLogin()
        }
    }
}

// MARK: - OIDAuthStateChangeDelegate

extension MenuView: OIDAuthStateChangeDelegate {
    func didChange(_ state: OIDAuthState) {
        handleEmailRegistration()
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.reloadMenuDataSource()
        }
    }
    
    fileprivate func handleEmailRegistration() {
        let hasRegisteredEmail = UserDefaults.standard.bool(forKey: GTConstants.kUserEmailIsRegistered)
        if !hasRegisteredEmail && viewModel.loginClient.isAuthenticated() {
            viewModel.loginClient.fetchAttributes() { (attributes, _) in
                let signupManager = EmailSignUpManager()
                signupManager.signUpUserForEmailRegistration(attributes: attributes)
            }
        }
    }
}
