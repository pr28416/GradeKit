//
//  UtilitiesVC.swift
//  GradeKit
//
//  Created by Pranav Ramesh on 7/17/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import FirebaseAuth

class UtilitiesVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            if indexPath.row == 2 {
                // Sign out
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loadingVC = storyboard.instantiateViewController(identifier: "LoadingVC")
                    self.present(loadingVC, animated: true) {
                        NotificationCenter.default.post(name: .authLogout, object: nil)
                    }
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError)")
                }
            }
        default: break
        }
    }

}

class UnweightedGPAScaleVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeSwitch.isOn = options["Unweighted GPA Scale"] as! Double == 5.0
    }
    
    var isEnabled = false
    
    @IBOutlet weak var typeSwitch: UISwitch!
    @IBAction func typeSwitch(_ sender: UISwitch) {
        options["Unweighted GPA Scale"] = sender.isOn ? 5.0 : 4.0
        isEnabled = sender.isOn
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "A maximum unweighted GPA of \(isEnabled ? 5.0 : 4.0) will be attainable when creating grade sheets."
        default: return nil
        }
        
    }
    
}

class WeightedGPAScaleVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
