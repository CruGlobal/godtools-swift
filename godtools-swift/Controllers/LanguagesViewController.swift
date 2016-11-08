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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchLanguages()
    }
    
    func fetchLanguages () {
        let sort = NSSortDescriptor(key: "name", ascending: true)
        let fetchRequest = NSFetchRequest<GodToolsLanguage>(entityName: "GodToolsLanguage")
        
        fetchRequest.sortDescriptors = [sort]
        
        languageFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: GodToolsPersistence.context(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try languageFetchController!.performFetch()
        } catch {
            print("error...")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLanguage = languageFetchController!.object(at: IndexPath.init(row: indexPath.section, section: indexPath.row));
        GodToolsSettings.init().setPrimaryLanguage(code: selectedLanguage.code!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (languageFetchController!.fetchedObjects?.count)!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if (cell == nil) {
            cell = UITableViewCell.init()
        }
        
        let lang = languageFetchController!.object(at: IndexPath.init(row: indexPath.section, section: indexPath.row))
        
        cell?.textLabel?.text = "\(lang.name!)"
        cell?.textLabel?.textColor = .white
        cell?.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        
        return cell!
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
