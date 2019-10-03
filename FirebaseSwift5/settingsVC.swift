//
//  settingsVC.swift
//  FirebaseSwift5
//
//  Created by Joshua Mac Guinness on 31/8/19.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import UIKit
import Firebase

class settingsVC: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        
    }
    
    
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
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        // load pdf into webView
        self.tabBarController?.navigationItem.title = "Settings"
        
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
            self.present(alertController, animated: true)        }
    }

}
