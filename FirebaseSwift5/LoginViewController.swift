//
//  ViewController.swift
//  FirebaseSwift5
//
//  Created by Wei Lian Chin on 26/08/2019.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

extension UIView {

func dropShadow(scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.125
    layer.shadowOffset = CGSize.zero
    layer.shadowRadius = 5
    layer.cornerRadius = 7
}}

class LoginViewController: UIViewController , UITextFieldDelegate{
    let defaults = UserDefaults.standard
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var checkBoxSwitch: UISwitch!
    @IBOutlet weak var RememberSwitch: UISwitch!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var fieldView2: UIView!
    
    
    var db : Firestore!
    var ref: DatabaseReference!
    var number_of_logs = 0
    
    
    
    override func viewDidLoad() {
        
        fieldView.dropShadow(scale: true)
        fieldView2.dropShadow(scale: true)
        loginButton.dropShadow(scale: true)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        db = Firestore.firestore()
        ref = Database.database().reference()
        password.delegate = self
        password.keyboardType = UIKeyboardType.numberPad
        RememberSwitch.setOn(false, animated: false)
        
        ref.child("logs").child("number_of_logs").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            self.number_of_logs = (snapshot.value as? Int)!
            self.loginButton.isEnabled = true

            
            
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        

        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if defaults.bool(forKey: "RememberMe"){
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "goHome", sender: nil)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    
    @IBAction func termsConditionsClick(_ sender: Any) {
        performSegue(withIdentifier: "showTC", sender: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 6
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
        
    }
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        var loginemail = ""
        var isAdmin : Bool = false
        var datalength :  Int = 0
        var counter : Int = 0
        db.collection("user").getDocuments(){
            querySnapshot, error in
            if let error = error{
                print("\(error.localizedDescription)")
            }else{
                for document in querySnapshot!.documents {
                    datalength = querySnapshot!.count
                    
                    if document.data()["username"] as? String == self.email.text!{
                        
                        loginemail = document.data()["email"] as! String
                        isAdmin = document.data()["admin"] as! Bool
                        Auth.auth().signIn(withEmail: loginemail, password: self.password.text!){
                            (user,error) in
                            if error != nil {
                                let alertController = UIAlertController(title: "Error", message: "Incorrect email address and / or password.", preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                                self.save_logs(condition: "failed")
                                
                                
                            }else {
                                print ("Login successfully")
                                self.save_logs(condition: "successful")
                                if self.RememberSwitch.isOn == false{
                                    self.defaults.set(false, forKey: "RememberMe")
                                }
                                if isAdmin{
                                    self.performSegue(withIdentifier: "goHome", sender: self)
                                }else{
                                    self.performSegue(withIdentifier: "goHome", sender: self)
                                }
                            }
                        }
                    }else{
                        counter = counter + 1
                        print ("datalength:" ,datalength)
                        print ("counter:",counter)
                    if counter == datalength{
                        let alertController = UIAlertController(title: "Error", message: "Incorrect email address and / or password.", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                        self.save_logs(condition: "failed")
                    
                    }
                    }
                }
               
            }
        }
        
        
    }
//        Auth.auth().signIn(withEmail: email.text! , password: password.text!){
//            (user, error) in
//            if error != nil {
//                print (error!)
//            }else {
//                print("Login successful")
//                if self.RememberSwitch.isOn == false{
//                    self.defaults.set(false, forKey: "RememberMe")
//                }
//                self.performSegue(withIdentifier: "goHome", sender: self)
//
//            }
//        }
//    }
    func add_number_of_logs(){
        self.number_of_logs += 1
        self.ref.child("logs/number_of_logs").setValue(self.number_of_logs)
    }
    
    func save_logs(condition : String){
        if condition == "successful"{
        self.ref.child("logs/login_attempts/successful/\(self.number_of_logs)/message").setValue( "\(self.email.text!) is successfully login at \(Date())")
        self.ref.child("logs/login_attempts/successful/\(self.number_of_logs)/timestamp").setValue( "\(Timestamp())")
        }
        else {
            
        self.ref.child("logs/login_attempts/failed/\(self.number_of_logs)/message").setValue( "Anonymous attempts login to the application but failed at \(Date())")
            self.ref.child("logs/login_attempts/failed/\(self.number_of_logs)/timestamp").setValue( "\(Timestamp(date: Date()))")
        }
        self.add_number_of_logs()
    }
//    @IBAction func switchChange(_ sender: Any) {
//        if checkBoxSwitch.isOn {
//            loginButton.isEnabled = true
//            self.loginButton.backgroundColor = UIColor(red: 149/255, green: 252/255, blue: 189/255, alpha: 1)
//            self.loginButton.setTitleColor(.white, for: .normal)
//        }
//        else {
//            loginButton.isEnabled = false
//            self.loginButton.backgroundColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 0.5)
//            self.loginButton.setTitleColor(.black, for: .normal)
//        }
//    }
    
    @IBAction func rememberChange(_ sender: Any) {
        if RememberSwitch.isOn{
            defaults.set(true, forKey: "RememberMe")
        }
        else{
            defaults.set(false, forKey: "RememberMe")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        email.resignFirstResponder()
        password.resignFirstResponder()
        return(true)
    }
   
}

