//
//  LoadingVC.swift
//  GradeKit
//
//  Created by Pranav Ramesh on 7/20/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoadingVC: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(authLogin(_:)), name: .authLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(authLogin(_:)), name: .authLogout, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, usr) in
            guard let user = auth.currentUser else {
                print("No user")
                self.performSegue(withIdentifier: "showAuth", sender: nil)
                return
            }
            guard let email = user.email else {
                print("Error verifying user email")
                return
            }
            print("Handle found user")
            NotificationCenter.default.post(name: .authLogin, object: nil, userInfo: [
                "Email": email as String,
                "UID": user.uid as String
            ])
        }
    }

    @objc func authLogin(_ notification: Notification) {
        print("Securing login data...")
        if let data = notification.userInfo as? [String:String] {
            if let email = data["Email"] {
                let uid = data["UID"] ?? "N/A"
                print("Login details: \(email), \(uid)")
                // Transfer to MainVC
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainTabVC = storyboard.instantiateViewController(identifier: "mainTabVC") as! UITabBarController
                self.present(mainTabVC, animated: true) {
                    // Remove login listener
                    Auth.auth().removeStateDidChangeListener(self.handle!)
                }
            }
        }
    }
    
    @objc func authLogout(_ notification: Notification?) {
        print("Logging out...")
    }
}
