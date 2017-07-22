//
//  SettingViewController.swift
//  mp3cube
//
//  Created by INSU BYEON on 22/07/2017.
//  Copyright © 2017 kokonoe. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("section: \(indexPath.section)")
        //print("row: \(indexPath.row)")
        switch indexPath.row {
        case 0:
            print("goto dev home")
            break
            
        default:
            break
            
        }
    }
    
}
