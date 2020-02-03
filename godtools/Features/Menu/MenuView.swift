//
//  MenuView.swift
//  godtools
//
//  Created by Devserker on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import MessageUI
import TheKeyOAuthSwift
import GTMAppAuth

protocol MenuViewControllerDelegate: class {
    func moveToUpdateLanguageSettings()
    func moveToAbout()
    func openWebView(url: URL, title: String, analyticsTitle: String)
}

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


class MenuView: BaseViewController {
    
    private let viewModel: MenuViewModelType
    private let headerHeight: CGFloat = 40.0
    private let rowHeight: CGFloat = 50
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: MenuViewControllerDelegate?
    
    var isComingFromLoginBanner = false
    
    required init(viewModel: MenuViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: "MenuView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var screenTitle: String {
        get {
            return "settings".localized
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBinding()
        
        viewModel.loginClient.addStateChangeDelegate(delegate: self)
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
        
        viewModel.menuDataSource.addObserver(self) { [weak self] (menuDataSource: MenuDataSource) in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reloadMenuDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isComingFromLoginBanner {
            openLoginWindow()
            isComingFromLoginBanner = false
        }
    }
    
    // MARK: - Navigation Buttons
    
    override func configureNavigationButtons() {
        addEmptyLeftButton()
        addDoneButton()
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Menu"
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
        cell.configure(viewModel: MenuCellViewModel(menuItem: menuItem))
        
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
        titleLabel.text = section.title.capitalized
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let menuItem: MenuItem = viewModel.menuDataSource.value.getMenuItem(at: indexPath)
        
        switch menuItem.id {
            
        case .languageSettings:
            delegate?.moveToUpdateLanguageSettings()
        
        case .about:
            delegate?.moveToAbout()
        
        case .help:
            let url = URL(string: "http://www.godtoolsapp.com/faq")
            delegate?.openWebView(url: url!, title: "help".localized, analyticsTitle: "Help")
        
        case .contactUs:
            if MFMailComposeViewController.canSendMail() {
                sendEmail(recipient: "support@godtoolsapp.com", subject: "Email to GodTools support")
            } else {
                let url = URL(string: "http://www.godtoolsapp.com/#contact")
                delegate?.openWebView(url: url!, title: "contact_us".localized, analyticsTitle: "Contact Us")
            }
        
        case .logout:
            DispatchQueue.main.async { [weak self] in
                self?.presentLogoutConfirmation()
            }
            
        case .login:
            initiateLogin()
        
        case .createAccount:
            initiateLogin(additionalParameters: ["action":"signup"])
        
        case .shareGodTools:
            let textToShare = [ "share_god_tools_share_sheet_text".localized ]
            let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
            
            var userInfo: [String: Any] = [AdobeAnalyticsConstants.Keys.shareAction: 1]
            userInfo["action"] = AdobeAnalyticsConstants.Values.share
            NotificationCenter.default.post(name: .actionTrackNotification,
                                            object: nil,
                                            userInfo: userInfo)
            sendScreenViewNotification(screenName: "Share App", siteSection: siteSection(), siteSubSection: siteSubSection())
            present(activityViewController, animated: true, completion: nil)
        
        case .shareAStoryWithUs:
            if MFMailComposeViewController.canSendMail() {
                sendEmail(recipient: "support@godtoolsapp.com", subject: "GodTools story")
            } else {
                let url = URL(string: "http://www.godtoolsapp.com/#contact")
                delegate?.openWebView(url: url!, title: "share_a_story_with_us".localized, analyticsTitle: "Share Story")
            }
            sendScreenViewNotification(screenName: "Share Story", siteSection: siteSection(), siteSubSection: siteSubSection())
        
        case .termsOfUse:
            let url = URL(string: "https://godtoolsapp.com/terms-of-use/")
            delegate?.openWebView(url: url!, title: "terms_of_use".localized, analyticsTitle: "Terms of Use")
        
        case .privacyPolicy:
            let url = URL(string: "https://www.cru.org/about/privacy.html")
            delegate?.openWebView(url: url!, title: "privacy_policy".localized, analyticsTitle: "Privacy Policy")
        
        case .copyrightInfo:
            let url = URL(string: "http://www.godtoolsapp.com/copyright")
            delegate?.openWebView(url: url!, title: "copyright_info".localized, analyticsTitle: "Copyright Info")
            
        case .tutorial:
            viewModel.tutorialTapped()
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

// MARK: - MFMailComposeViewControllerDelegate

extension MenuView: MFMailComposeViewControllerDelegate {
    
    func sendEmail(recipient: String, subject: String) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([ recipient ])
        composeVC.setSubject(subject)
        present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
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
