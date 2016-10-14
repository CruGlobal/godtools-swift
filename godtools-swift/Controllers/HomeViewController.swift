//
//  ViewController.swift
//  godtools-swift
//
//  Created by Ryan Carlson on 10/12/16.
//  Copyright © 2016 Cru. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.init(colorLiteralRed: 0.4375, green: 0.8359, blue: 0.875, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let titleAttributesDictionary: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = (titleAttributesDictionary as! [String : Any])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GodtoolsAPI.sharedInstance.getAccessToken()
    }

    @IBAction func settingsButtonWasPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "homeToSettingsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
}

