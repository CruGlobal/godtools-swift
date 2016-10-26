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

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (languageFetchController!.fetchedObjects?.count)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if (cell == nil) {
            cell = UITableViewCell.init()
        }

        cell?.textLabel?.text = languageFetchController!.object(at: indexPath).name
 g        cell?.textLabel?.textColor = UIColor.white
        cell?.backgroundColor = UIColor.clear
        
        return cell!
    }
}
