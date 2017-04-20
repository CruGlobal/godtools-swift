//
//  ViewController.swift
//  godtools
//
//  Created by Ryan Carlson on 4/18/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonWasPressed(_ sender: Any) {
        let languagesVC = LanguagesViewController(nibName: String.init(describing: LanguagesViewController.self), bundle: nil)
        
        present(languagesVC, animated: true, completion: nil)
    }

}

