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

class LanguagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var languages: Array<GodToolsLanguage> = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let persistenceContext = GodToolsPersistence.init()
        let languagesFetch: NSFetchRequest<GodToolsLanguage> = GodToolsLanguage.fetchRequest()

        do {
            let results = try persistenceContext.managedObjectContext.fetch(languagesFetch)
            
            for language in results {
                languages.append(language)
            }
        } catch {
            debugPrint("Error loading languages: \(error)")
        }
        
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
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
    
        cell?.textLabel?.text = languages[indexPath.row].name
        cell?.textLabel?.textColor = UIColor.white
        cell?.backgroundColor = UIColor.clear
        
        return cell!
    }
}
