//
//  SettingsViewController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/12/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit
import CoreData

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 0.4375, green: 0.8359, blue: 0.875, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let titleAttributesDictionary: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleAttributesDictionary as! [String : Any])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func primaryLanguageSelectionButtonWasPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "settingsToLanguagesSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
}
