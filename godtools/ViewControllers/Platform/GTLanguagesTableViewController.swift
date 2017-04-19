//
//  GTLanguagesTableViewController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class GTLanguagesTableViewController: GTBaseTableViewController {
    var languages: NSMutableArray = []
    let languageCell = "languageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerCells()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.languageCell, for: indexPath)
        return cell
    }
    
    // MARK: - Helpers
    
    func registerCells() {
        self.tableView .register(GTLanguageTableViewCell.classForKeyedArchiver(), forCellReuseIdentifier: self.languageCell)
    }
    
}
