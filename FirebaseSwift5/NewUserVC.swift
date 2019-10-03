//
//  NewUserVC.swift
//  FirebaseSwift5
//
//  Created by Joshua Mac Guinness on 31/8/19.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

extension UIView {

func dropShadow1(scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.125
    layer.shadowOffset = CGSize.zero
    layer.shadowRadius = 5
    layer.cornerRadius = 7
}}

class NewUserVC: UIViewController,UITextFieldDelegate {

    var db: Firestore!

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var AdminSwitch: UISwitch!
    
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var fieldView2: UIView!
    @IBOutlet weak var fieldView3: UIView!
    @IBOutlet weak var loginButton: UIButton!
    
    
    
    var error_message1 : String = ""
    var error_message2 : String = ""
    var final_error_message : String = ""
    var registered_username = [String]()
    var registered_email = [String]()
    var testusername : String = ""
    var testuseremail : String = ""
    var suitable_username : Bool = true
    var suitable_email : Bool = true
    
    
    override func viewDidLoad() {
        
        fieldView.dropShadow(scale: true)
        fieldView2.dropShadow(scale: true)
        fieldView3.dropShadow(scale: true)
        loginButton.dropShadow(scale: true)
        
        super.viewDidLoad()
        passwordTF.delegate = self 
        passwordTF.keyboardType = UIKeyboardType.numberPad
        db = Firestore.firestore()
        db.collection("user").getDocuments(){
            querySnapshot, error in
            if let error = error{
                print("\(error.localizedDescription)")
            }else{
                for document in querySnapshot!.documents {
                    
                    if let username = document.data()["username"] as? String {
                        self.registered_username.append(username)
                    }
                    if let email = document.data()["email"] as? String {
                        self.registered_email.append(email)
                    }
                }
            }
        }
    }
    
    
    @IBAction func onSignUpTapped(_ sender: Any) {
        var admin_condition : Bool = false
        if suitable_email && suitable_username{
            
            if AdminSwitch.isOn {
                admin_condition = true
            }else{
                admin_condition = false
            }
            var ref: DocumentReference? = nil
            ref = db.collection("user").addDocument(data: [
                "username": usernameTF.text!,
                "email": emailTF.text!,
                "admin": admin_condition
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
            let signUpManager = FirebaseAuthManager()
            if let email = self.emailTF.text, let password = self.passwordTF.text {
                signUpManager.createUser(email: email, password: password) {[weak self] (success) in
                    guard let `self` = self else { return }
                    var message: String = ""
                    if (success) {
                        message = "User was sucessfully created."
                    } else {
                        message = "There was an error."
                    }
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true)
                    //                self.performSegue(withIdentifier: "returnHome", sender: self)
                    self.setdefault()
                    self.registered_username.append(self.usernameTF.text!)
                    self.registered_email.append(self.emailTF.text!)
                }
            }
        }
            
            else{
                final_error_message = error_message1 + error_message2
                let alertController2 = UIAlertController(title: "Error", message: final_error_message, preferredStyle: .alert)
                let defaultAction2 = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController2.addAction(defaultAction2)
                self.present(alertController2, animated: true, completion: nil)
                self.setdefault()
            }
        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 6
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "User"
        
    }
    
    
    @IBAction func UsernameEditingEnd(_ sender: Any) {
        testusername = usernameTF.text!
        if registered_username.contains(testusername){
            print ("Username already registered")
            usernameTF.layer.masksToBounds = false
            usernameTF.layer.shadowRadius = 3.0
            usernameTF.layer.shadowColor = UIColor.red.cgColor
            usernameTF.layer.shadowOpacity = 2.0
            
            suitable_username = false
            self.error_message1 = "Username already registered. \n"
        }else{
            self.error_message1 = ""
            usernameTF.layer.shadowOpacity = 0.0
            suitable_username = true
        }
    }
    
    @IBAction func EmailEditingEnd(_ sender: Any) {
        testuseremail = emailTF.text!
        if registered_email.contains(testuseremail){
            print ("Email already registered")
            emailTF.layer.masksToBounds = false
            emailTF.layer.shadowRadius = 3.0
            emailTF.layer.shadowColor = UIColor.red.cgColor
            emailTF.layer.shadowOpacity = 2.0
            
            suitable_email = false
            self.error_message2 = "Email already registered. \n"
        }else{
            self.error_message2 = ""
            emailTF.layer.shadowOpacity = 0.0
            suitable_email = true
        }
        }
    
    func setdefault(){
        
        self.emailTF.text = ""
        self.passwordTF.text = ""
        self.usernameTF.text = ""
        self.AdminSwitch.setOn(false, animated: false)
        emailTF.layer.shadowOpacity = 0.0
        usernameTF.layer.shadowOpacity = 0.0
        suitable_username = true
        suitable_email = true
    }
}
    



