//
//  SettingsController.swift
//  Thrifa
//
//  Created by Quang Nguyen on 7/9/16.
//  Copyright © 2016 Quang Nguyen. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {

    let defaults = NSUserDefaults.standardUserDefaults()
    @IBOutlet var highlightLabel: UILabel!
    @IBOutlet var highlightSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func highLightSwitchAction(sender: UISwitch) {
        
        if (sender.on)
        {
            //highlightLabel.text = "ON"
            defaults.setBool(true, forKey: "settings")
        }
        else
        {
            
            //highlightLabel.text = "OFF"
            defaults.setBool(false, forKey: "settings")
        }
    }
    
    
    @IBAction func FocusOnCurrentLocation(sender: UISwitch) {
        
        if (sender.on)
        {
            //highlightLabel.text = "ON"
            defaults.setBool(true, forKey: "zoom")
        }
        else
        {
            
            //highlightLabel.text = "OFF"
            defaults.setBool(false, forKey: "zoom")
        }
        
    }
    



}
