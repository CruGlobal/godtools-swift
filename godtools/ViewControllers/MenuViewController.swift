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
    let header = ["general", "share", "legal"]
    
    override var screenTitle: String {
        get {
            return "settings".localized
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
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
    
    fileprivate func registerCells() {
        self.tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: self.menuCellIdentifier)
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

}
