//
//  SettingsViewController.swift
//  IRRandomUser
//
//  Created by Ihor Rudych on 4/6/18.
//  Copyright © 2018 Ihor Rudych. All rights reserved.
//

import Foundation
import UIKit

//little controler with delegate protocol to pass the batch size not to crowd main screen.
protocol SettingsViewControllerDelegate{
    func passUserBatchSize(size:Int)
}
class SettingsViewController:UIViewController{
    
    var delegate:SettingsViewControllerDelegate?
    
    var size:Int!
    
    @IBOutlet weak var sizeSwitcher: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if size == 5{
            self.sizeSwitcher.selectedSegmentIndex = 0
        } else if size == 10{
            self.sizeSwitcher.selectedSegmentIndex = 1
        }
    }
    
    @IBAction func sizeSwitched(_ sender: Any) {
        switch self.sizeSwitcher.selectedSegmentIndex {
        case 0:
            self.size = 5
        case 1:
            self.size = 10
        default:
            self.size = 5
        }
    }
    @IBAction func donePressed(_ sender: Any) {
        
        self.delegate?.passUserBatchSize(size: self.size)
        self.dismiss(animated: true, completion: nil)
        
    }
    

}
