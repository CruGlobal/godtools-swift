//
//  ViewController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/12/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import UIKit
import CoreData
import PromiseKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GTAboutViewControllerDelegate, GTViewControllerMenuDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var packagesFetchController :NSFetchedResultsController<GodToolsPackage>? = nil
    
    //MARK: - UIViewController lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 0.4375, green: 0.8359, blue: 0.875, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let titleAttributesDictionary: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleAttributesDictionary as! [String : Any])
        
        tableView.register(UINib(nibName: "PackageTableViewCell", bundle: nil), forCellReuseIdentifier: "packageCell")
        
        _ = MetaDataController.init().updateFromRemote().then {result -> Void in
            _ = PackageDataController.init().updateFromRemote()
            self.fetchPackages()
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPackages()
        self.tableView.reloadData()
    }
    
    //MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let package = packagesFetchController?.object(at: indexPath)
        let fileLoader = GTFileLoader.init()
        fileLoader.language = GodToolsSettings.init().primaryLanguage()!
        
        let vc :GTViewController = GTViewController .init(configFile: package?.configFilename!,
                                                          frame: self.view.frame,
                                                          packageCode: package?.code!,
                                                          langaugeCode: GodToolsSettings.init().primaryLanguage()!,
                                                          fileLoader: fileLoader,
                                                          shareInfo: GTShareInfo.init(),
                                                          pageMenuViewController: GTPageMenuViewController.init(),
                                                          aboutViewController: GTAboutViewController.init(delegate: self, fileLoader: fileLoader),
                                                          delegate: self)
        
        vc.loadResource(withConfigFilename: package?.configFilename!)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }

    //MARK: - UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (packagesFetchController?.fetchedObjects?.count)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell :PackageTableViewCell? = tableView.dequeueReusableCell(withIdentifier: "packageCell") as? PackageTableViewCell
        
        let package = packagesFetchController!.object(at: indexPath)
        cell?.configureFrom(package: package)
        
        return cell!
    }

    //MARK: - GTAboutViewControllerDelegate methods
    
    func viewOfPageViewController () -> UIView {
        return self.view
    }
    
    //MARK: - UIButton Listener Methods
    
    @IBAction func settingsButtonWasPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "homeToSettingsSegue", sender: self)
    }
    
    //MARK: - Other methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    func fetchPackages () {
        let fetchRequest = NSFetchRequest<GodToolsPackage>(entityName: "GodToolsPackage")
        let code = GodToolsSettings.init().primaryLanguage()
        
        fetchRequest.predicate = NSPredicate(format: "language.code == %@", code == nil ? "en" : code!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "code", ascending: true)]
        
        packagesFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: GodToolsPersistence.context(),
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try packagesFetchController!.performFetch()
        } catch {
            print("error...")
        }
    }
}

