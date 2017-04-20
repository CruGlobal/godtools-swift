//
//  GTLanguagesTableViewController.swift
//  godtools
//
//  Created by Devserker on 4/19/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

protocol LanguagesTableViewControllerDelegate {
}

class LanguagesTableViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: LanguagesTableViewControllerDelegate?
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.languageCell, for: indexPath)
        return cell
    }
    
    // MARK: - Helpers
    
    func registerCells() {
        self.tableView .register(LanguageTableViewCell.classForKeyedArchiver(), forCellReuseIdentifier: self.languageCell)
    }
    
}
