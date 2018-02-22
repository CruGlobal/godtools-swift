//
//  MenuViewController.swift
//  godtools
//
//  Created by Devserker on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit
import MessageUI

protocol MenuViewControllerDelegate {
    mutating func moveToUpdateLanguageSettings()
    mutating func moveToAbout()
    mutating func moveToLogin()
    mutating func openWebView(url: URL, title: String, analyticsTitle: String)
}

class MenuViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let general = ["language_settings", "about", "help", "contact_us"]
    // when login becomes available, use general below:
//    let general = ["language_settings", "login", "about", "help", "contact_us"]
    let share = ["share_god_tools", "share_a_story_with_us"]
    let legal = ["terms_of_use", "privacy_policy", "copyright_info"]
    let header = ["menu_general", "menu_share", "menu_legal"]
    
    let headerHeight: CGFloat = 40.0
    
    var delegate: MenuViewControllerDelegate?
    
    override var screenTitle: String {
        get {
            return "settings".localized
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UI
    
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
        self.tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: MenuViewController.menuCellIdentifier)
    }
    
    // MARK: - Analytics
    
    override func screenName() -> String {
        return "Menu"
    }

}

extension MenuViewController: UITableViewDataSource {
    
    static let menuCellIdentifier = "cellIdentifier"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let values = self.getSectionData(indexPath.section)
        let value = values[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuViewController.menuCellIdentifier) as! MenuTableViewCell
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

extension MenuViewController: UITableViewDelegate {
    
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
        switch indexPath.section {
        case 0:
            handleGeneralSectionCellSelection(rowIndex: indexPath.row)
            break
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

extension MenuViewController {
    
    // use this function when login becomes available. rename it to: handleGeneralSectionCellSelection.
    fileprivate func handleGeneralSectionCellSelectionFuture(rowIndex: Int) {
        switch rowIndex {
        case 0:
            delegate?.moveToUpdateLanguageSettings()
            break
        case 1:
            delegate?.moveToLogin()
            break
        case 2:
            delegate?.moveToAbout()
            break
        case 2:
            openHelp()
            break
        case 3:
            contactUs()
            break
        default: break
        }
        if rowIndex == 0 {
        }
    }
    
    fileprivate func handleGeneralSectionCellSelection(rowIndex: Int) {
        switch rowIndex {
        case 0:
            delegate?.moveToUpdateLanguageSettings()
            break
        case 1:
            delegate?.moveToAbout()
            break
        case 2:
            openHelp()
            break
        case 2:
            contactUs()
            break
        default: break
        }
        if rowIndex == 0 {
        }
    }
    
    fileprivate func handleShareSectionCellSelection(rowIndex: Int) {
        switch rowIndex {
        case 0:
            shareGodToolsApp()
            break
        case 1:
            shareAStoryWithUs()
        default: break
        }
    }
    
    fileprivate func handleLegalSectionCellSelection(rowIndex: Int) {
        switch rowIndex {
        case 0:
            openTermsOfUse()
            break
        case 1:
            openPrivacyPolicy()
            break
        case 2:
            openCopyrightInfo()
            break
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
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    fileprivate func shareAStoryWithUs() {
        if MFMailComposeViewController.canSendMail() {
            sendEmail(recipient: "support@godtoolsapp.com", subject: "GodTools story")
        } else {
            let url = URL(string: "http://www.godtoolsapp.com/#contact")
            self.delegate?.openWebView(url: url!, title: "share_a_story_with_us".localized, analyticsTitle: "Share Story")
        }
    }
    
    fileprivate func openTermsOfUse() {
        let url = URL(string: "http://www.godtoolsapp.com/user-agreement/")
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
    
}

extension MenuViewController: MFMailComposeViewControllerDelegate {
    
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

extension MenuViewController: MenuTableViewCellDelegate {
    func menuNextButtonWasPressed(sender: MenuTableViewCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            tableView(tableView, didSelectRowAt: indexPath)
            sender.setSelected(true, animated: false)
        }
    }
}
