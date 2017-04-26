//
//  MenuViewController.swift
//  godtools
//
//  Created by Devserker on 4/24/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class MenuViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    enum MenuCellKind {
        case link
        case option
    }
    
    @IBOutlet weak var tableView: UITableView!
    let menuCellIdentifier = "cellIdentifier"
    
    let general = ["language_settings", "about", "help", "contact_us", "notifications", "preview_mode_translators_only"]
    let share = ["share_god_tools", "share_a_story_with_us"]
    let legal = ["terms_of_use", "privacy_policy"]
    let header = ["menu_general", "menu_share", "menu_legal"]
    
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
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let values = self.getSectionData(indexPath.section)
        let value = values[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: self.menuCellIdentifier) as! MenuTableViewCell
        cell.value = value
        
        if value == "notifications" || value == "preview_mode_translators_only" {
            cell.isSwitchCell = true
        }
        else {
            cell.isSwitchCell = false
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.header.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let values = self.getSectionData(section)
        return values.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    fileprivate func setupStyle() {
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .gtGreyLight
        self.registerCells()
    }
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: self.menuCellIdentifier)
    }
    
    fileprivate func getSection(_ section: Int) -> String {
        return header[section]
    }
    
    fileprivate func getSectionData(_ section: Int) -> Array<String> {
        var values = Array<String>()
        if section == 0 {
            values = self.general
        }
        else if section == 1 {
            values = self.share
        }
        else {
            values = self.legal
        }
        return values
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 40)
        let headerView:UIView = UIView(frame: headerFrame)
        headerView.backgroundColor = .gtGreyLight
        
        let labelFrame = CGRect(x: 32.0, y: 11.0, width: 100.0, height: 18.0)
        let titleLabel:GTLabel = GTLabel(frame: labelFrame)
        titleLabel.gtStyle = "blackTextSmall"
        titleLabel.text = self.getSection(section).localized.capitalized
        headerView.addSubview(titleLabel)
        
        return headerView
    }

}
