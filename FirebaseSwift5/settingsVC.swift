//
//  settingsVC.swift
//  FirebaseSwift5
//
//  Created by Joshua Mac Guinness on 31/8/19.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import UIKit
import Firebase

// MARK: - Initial Declerations

class settingsVC: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var fieldView3: UIView!
    
    override func viewDidLoad() {
        fieldView3.dropShadow(scale: true)
        passwordButton.dropShadow(scale: true)
        logOutButton.dropShadow(scale: true)
    }
    
    // MARK: - User Handeling

    @IBAction func logOutPress(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    
    @IBAction func resetPasswordClicked(_ sender: Any) {
        let email = emailTextField.text!
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            var message: String = ""
            if ((error) == nil) {
                message = "Password Update Email Sent"
            } else {
                message = "There was an error."
            }
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true)
            self.emailTextField.text = ""
        }
    }
    
    
    // MARK: - View Config
    
    override func viewDidAppear(_ animated: Bool) {
        // load pdf into webView
        self.tabBarController?.navigationItem.title = "Settings"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

}
