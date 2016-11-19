//
//  LanguagesViewController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/12/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class LanguagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var languageFetchController : NSFetchedResultsController<GodToolsLanguage>? = nil
    
    var languages : Array<GodToolsLanguage> = []

    //MARK: - UIViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        languageFetchController = MetaDataController.init().loadFromLocal()
    }
    
    //MARK: - UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return (languageFetchController!.fetchedObjects?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if (cell == nil) {
            cell = UITableViewCell.init()
        }
        
        let lang = languageFetchController!.object(at: IndexPath.init(row: indexPath.section, section: indexPath.row))
        
        cell?.textLabel?.text = "\(lang.name!)"
        cell?.textLabel?.textColor = .white
        
        if (lang.downloaded) {
            cell?.backgroundColor = UIColor.red
        } else {
            cell?.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        }
        return cell!
    }
    
    //MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = languageFetchController!.object(at: IndexPath.init(row: indexPath.section, section: indexPath.row));
        
        GodToolsSettings.sharedSettings.setPrimaryLanguage(code: selectedLanguage.code!)
        
        if (!selectedLanguage.downloaded) {
            _ = PackageDataController.init().updateFromRemote().then(execute: { (language) in
                _ = self.navigationController?.popViewController(animated: true)
            })
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x :0, y :0, width :self.tableView.frame.width, height :10.0))
        view.backgroundColor = .clear
        
        return view
    }
}
