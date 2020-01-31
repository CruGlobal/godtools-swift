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
    
    @IBOutlet weak var tableView: UITableView!

    var general = [String]()
    let generalNonEnglishMenu = ["language_settings", "about", "help", "contact_us"]
    let generalWithLogout = ["language_settings", "logout", "about", "help", "contact_us"]
    let generalWithLogin = ["language_settings", "login", "create_account", "about", "help", "contact_us"]
    let share = ["share_god_tools", "share_a_story_with_us"]
    let legal = ["terms_of_use", "privacy_policy", "copyright_info"]
    let header = ["menu_general", "menu_share", "menu_legal"]
    
    // MARK: - This array could possible extend to more languages over time.
    let languageLoginCodes = ["en"]
    
    let headerHeight: CGFloat = 40.0
    
    var delegate: MenuViewControllerDelegate?
    let loginClient =  TheKeyOAuthClient.shared
    
    var isComingFromLoginBanner = false
    let intWithCreateAccount = 6
    let intWithoutCreateAccount = 5
    let intWithNonEnglishMenu = 4
    
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
        adjustGeneralTitles()
        loginClient.addStateChangeDelegate(delegate: self)
        self.setupStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustGeneralTitles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isComingFromLoginBanner {
            openLoginWindow()
            isComingFromLoginBanner = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UI
    
    // MARK: - Currently the 'General' menu items will only have Login/Logout option if the device is in English. This may change over time, so if other languages are added, their language code can be added
    
    func adjustGeneralTitles() {
        let codeForLanguage = Locale.current.languageCode ?? "unknown"
        if languageLoginCodes.contains(codeForLanguage) {
            general = (loginClient.isAuthenticated()) ? generalWithLogout : generalWithLogin
        } else {
            general = generalNonEnglishMenu
        }

        tableView.reloadData()
    }
    
    fileprivate func setupStyle() {
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .gtGreyLight
        self.registerCells()
    }
    
    // MARK: - Navigation Buttons
    
    override func configureNavigationButtons() {
        self.addEmptyLeftButton()
        self.addDoneButton()
    }
    
    // MARK: - Helpers
    
    fileprivate func getSection(_ section: Int) -> String {
        return header[section]
    }
    
    fileprivate func getSectionData(_ section: Int) -> Array<String> {
        var values = [String]()
        if section == 0 {
            values = self.general
        } else if section == 1 {
            values = self.share
        } else {
            values = self.legal
        }
        return values
    }
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: MenuView.menuCellIdentifier)
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Menu"
    }

}

extension MenuView: UITableViewDataSource {
    
    static let menuCellIdentifier = "cellIdentifier"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let values = self.getSectionData(indexPath.section)
        let value = values[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuView.menuCellIdentifier) as! MenuTableViewCell
        cell.value = value
        
        if value == "notifications" || value == "preview_mode_translators_only" {
            cell.isSwitchCell = true
        } else {
            cell.isSwitchCell = false
        }
        
        cell.delegate = self
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.header.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let values = self.getSectionData(section)
        return values.count
    }
    
}

extension MenuView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: headerHeight)
        let headerView:UIView = UIView(frame: headerFrame)
        headerView.backgroundColor = .gtGreyLight
        
        let labelFrame = CGRect(x: 20.0, y: 12.0, width: 100.0, height: 16.0)
        let titleLabel:GTLabel = GTLabel(frame: labelFrame)
        titleLabel.gtStyle = "blackTextSmall"
        titleLabel.text = self.getSection(section).localized.capitalized
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            handleGeneralSectionCellSelection(rowIndex: indexPath.row)
        case 1:
            handleShareSectionCellSelection(rowIndex: indexPath.row)
        case 2:
            handleLegalSectionCellSelection(rowIndex: indexPath.row)
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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

//MARK: cell selection methods

extension MenuView {
    
    fileprivate func handleGeneralSectionCellSelection(rowIndex: Int) {
        switch general.count {
        case intWithNonEnglishMenu:
            selectionNonEnglishMenu(rowIndex: rowIndex)
        case intWithCreateAccount:
            selectionCreateAccountVisible(rowIndex: rowIndex)
        case intWithoutCreateAccount:
            selectionCreateAccountNotVisible(rowIndex: rowIndex)
        default: break
        }
    }
    
    fileprivate func selectionCreateAccountVisible(rowIndex: Int) {
        switch rowIndex {
        case 0:
            delegate?.moveToUpdateLanguageSettings()
        case 1:
            openLoginWindow()
        case 2:
            openCreateAccountWindow()
        case 3:
            delegate?.moveToAbout()
        case 4:
            openHelp()
        case 5:
            contactUs()
        default: break
        }
    }
    
    fileprivate func selectionCreateAccountNotVisible(rowIndex: Int) {
        switch rowIndex {
        case 0:
            delegate?.moveToUpdateLanguageSettings()
        case 1:
            openLoginWindow()
        case 2:
            delegate?.moveToAbout()
        case 3:
            openHelp()
        case 4:
            contactUs()
        default: break
        }
    }
    
    fileprivate func selectionNonEnglishMenu(rowIndex: Int) {
        switch rowIndex {
        case 0:
            delegate?.moveToUpdateLanguageSettings()
        case 1:
            delegate?.moveToAbout()
        case 2:
            openHelp()
        case 3:
            contactUs()
        default: break
        }
    }
    
    fileprivate func handleShareSectionCellSelection(rowIndex: Int) {
        switch rowIndex {
        case 0:
            shareGodToolsApp()
        case 1:
            shareAStoryWithUs()
        default: break
        }
    }
    
    fileprivate func handleLegalSectionCellSelection(rowIndex: Int) {
        switch rowIndex {
        case 0:
            openTermsOfUse()
        case 1:
            openPrivacyPolicy()
        case 2:
            openCopyrightInfo()
        default: break
        }
        
    }
    
    fileprivate func openHelp() {
        let url = URL(string: "http://www.godtoolsapp.com/faq")
        self.delegate?.openWebView(url: url!, title: "help".localized, analyticsTitle: "Help")
    }
    
    fileprivate func contactUs() {
        if MFMailComposeViewController.canSendMail() {
            sendEmail(recipient: "support@godtoolsapp.com", subject: "Email to GodTools support")
        } else {
            let url = URL(string: "http://www.godtoolsapp.com/#contact")
            self.delegate?.openWebView(url: url!, title: "contact_us".localized, analyticsTitle: "Contact Us")
        }
    }
    
    fileprivate func shareGodToolsApp() {
        let textToShare = [ "share_god_tools_share_sheet_text".localized ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        var userInfo: [String: Any] = [AdobeAnalyticsConstants.Keys.shareAction: 1]
        userInfo["action"] = AdobeAnalyticsConstants.Values.share
        NotificationCenter.default.post(name: .actionTrackNotification,
                                        object: nil,
                                        userInfo: userInfo)
        self.sendScreenViewNotification(screenName: "Share App", siteSection: siteSection(), siteSubSection: siteSubSection())
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    fileprivate func shareAStoryWithUs() {
        if MFMailComposeViewController.canSendMail() {
            sendEmail(recipient: "support@godtoolsapp.com", subject: "GodTools story")
        } else {
            let url = URL(string: "http://www.godtoolsapp.com/#contact")
            self.delegate?.openWebView(url: url!, title: "share_a_story_with_us".localized, analyticsTitle: "Share Story")
        }
        self.sendScreenViewNotification(screenName: "Share Story", siteSection: siteSection(), siteSubSection: siteSubSection())
    }
    
    fileprivate func openTermsOfUse() {
        let url = URL(string: "https://godtoolsapp.com/terms-of-use/")
        self.delegate?.openWebView(url: url!, title: "terms_of_use".localized, analyticsTitle: "Terms of Use")
    }
    
    fileprivate func openPrivacyPolicy() {
        let url = URL(string: "https://www.cru.org/about/privacy.html")
        self.delegate?.openWebView(url: url!, title: "privacy_policy".localized, analyticsTitle: "Privacy Policy")
    }
    
    fileprivate func openCopyrightInfo() {
        let url = URL(string: "http://www.godtoolsapp.com/copyright")
        self.delegate?.openWebView(url: url!, title: "copyright_info".localized, analyticsTitle: "Copyright Info")
    }
    
    fileprivate func openLoginWindow() {
        if loginClient.isAuthenticated() {
            DispatchQueue.main.async {
                self.presentLogoutConfirmation()
            }
        } else {
            initiateLogin()
        }
    }
    
    fileprivate func openCreateAccountWindow() {
        initiateLogin(additionalParameters: ["action":"signup"])
    }
    
}

extension MenuView: MFMailComposeViewControllerDelegate {
    
    func sendEmail(recipient: String, subject: String) {
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([ recipient ])
        composeVC.setSubject(subject)
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension MenuView: MenuTableViewCellDelegate {
    func menuNextButtonWasPressed(sender: MenuTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            tableView(tableView, didSelectRowAt: indexPath)
            sender.setSelected(true, animated: false)
        }
    }
}

extension MenuView {
    
    func initiateLogin(additionalParameters: [String: String]? = nil) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        delegate.currentAuthorizationFlow = loginClient.initiateAuthorization(requestingViewController: self, additionalParameters: additionalParameters, callback: { (_) in
            // block unused
        })
    }
    
    func presentLogoutConfirmation() {
       
        let dialogMessage = UIAlertController(title: "Proceed with GodTools logout?".localized, message: "You are about to logout of your GodTools account".localized, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "ok".localized, style: .default, handler: { [weak self] (_) in

            self?.loginClient.logout()
            self?.adjustGeneralTitles()
        })
        
        let cancel = UIAlertAction(title: "cancel".localized, style: .cancel) { (_) in }
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
}

extension MenuView: OIDAuthStateChangeDelegate {
    func didChange(_ state: OIDAuthState) {
        handleEmailRegistration()
        DispatchQueue.main.async {
            self.adjustGeneralTitles()
        }
    }
    
    fileprivate func handleEmailRegistration() {
        let hasRegisteredEmail = UserDefaults.standard.bool(forKey: GTConstants.kUserEmailIsRegistered)
        if !hasRegisteredEmail && loginClient.isAuthenticated() {
            loginClient.fetchAttributes() { (attributes, _) in
                let signupManager = EmailSignUpManager()
                signupManager.signUpUserForEmailRegistration(attributes: attributes)
            }
        }
    }
    
}
