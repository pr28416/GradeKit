//
//  SignupVC.swift
//  GradeKit
//
//  Created by Pranav Ramesh on 7/19/20.
//  Copyright © 2020 Pranav Ramesh. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

class SignupVC: UIViewController, UITextFieldDelegate {
    
    var db: Firestore!
    var ref: DocumentReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginImg.layer.cornerRadius = 7
        signupImg.layer.cornerRadius = 7
        loginImg.clipsToBounds = true
        signupImg.clipsToBounds = true
        
        self.navigationController?.navigationBar.isHidden = true
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        emailField.delegate = self
        passwordField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeAuth(_:)), name: .closeAuth, object: nil)
        
        db = Firestore.firestore()
    }
    
    @objc func closeAuth(_ notification: Notification) {
        self.dismiss(animated: true) {
            NotificationCenter.default.post(name: .authLogin, object: nil, userInfo: notification.userInfo)
        }
    }
    
    @IBOutlet weak var signupButton: AuthButton!
    @IBOutlet weak var loginButton: AuthButton!
    @IBOutlet weak var googleView: AuthButton!
    @IBOutlet weak var signupImg: UIImageView!
    @IBOutlet weak var loginImg: UIImageView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func signupButton(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text, email.count > 0, password.count > 0 else {
            raiseLoginError(message: "Email and password must be valid and greater than zero characters.")
            return
        }
        
        // Create new user
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            // Check for error
            if let error = error {
                self.raiseLoginError(message: error.localizedDescription)
                return
            }
            // Validate auth result
            guard let authResult = authResult else {return}
            guard let email = authResult.user.email else {return}
            print("Created user with email: \(email)")
            
            // Generate data
            let data = [
                "Email": email,
                "UID": authResult.user.uid
            ]
            
            // Create user in database
            self.db.collection("Users")
                .document("DetailedList")
                .collection("DetailedCollection")
                .document(authResult.user.uid)
                .setData(data, merge: true)
            
            
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: .authLogin, object: nil, userInfo: data)
            }
        }
    }
    
    func raiseLoginError(message: String) {
        let alert = UIAlertController(title: "Error", message: "There was an error when signing up: \(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func googleSignup(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
}

class LoginVC: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginImg.layer.cornerRadius = 7
        loginImg.clipsToBounds = true
        
        emailField.delegate = self
        passwordField.delegate = self

    }
    
    func raiseLoginError(message: String) {
        let alert = UIAlertController(title: "Error", message: "There was an error when signing up: \(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go back", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBOutlet weak var loginButton: AuthButton!
    @IBOutlet weak var loginImg: UIImageView!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginButton(_ sender: UIButton) {
        guard let email = emailField.text, let password = passwordField.text, email.count > 0, password.count > 0 else {
            raiseLoginError(message: "Email and password must be valid and greater than zero characters.")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                self.raiseLoginError(message: error.localizedDescription)
                return
            }
            
            guard let authResult = authResult else {return}
            if let email = authResult.user.email {
                 print("Signed in user with email: \(email)")
            } else {
                print("Signed in user with unknown email")
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let user = Auth.auth().currentUser {
            let signupVC = self.navigationController?.viewControllers[0] as! SignupVC
            print("closing view")
            signupVC.closeAuth(Notification(name: .closeAuth, object: nil, userInfo: [
                "Email": user.email ?? "N/A" as String,
                "UID": user.uid as String
            ]))
        }
    }
    
}

class AuthButton: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 7
        self.layer.shadowPath = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: 7).cgPath
        self.layer.cornerCurve = .continuous
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 8)
        self.layer.shadowRadius = 6
        self.layer.shadowOpacity = 0.15
        setNeedsLayout()
    }
}
