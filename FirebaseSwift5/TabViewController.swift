//
//  TabViewController.swift
//  FirebaseSwift5
//
//  Created by Wei Lian Chin on 29/08/2019.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
class TabViewController: UITabBarController {
let uid = ""
 var db : Firestore!
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        // Do any additional setup after loading the view.
        
        
        // MARK: - User Privilages
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            let email = user.email
            var isAdmin : Bool = false
            print(uid)
            print(email!)
            
            db.collection("user").getDocuments(){
                       querySnapshot, error in
                       if let error = error{
                           print("\(error.localizedDescription)")
                       }else{
                           for document in querySnapshot!.documents {
                            if document.data()["email"] as? String == email{
                            isAdmin = document.data()["admin"] as! Bool
                                if isAdmin{
                                    print("I am the admin")
                                }
                                else{
                                    print("im not the admin")
                                    let index1 = 1 //0 to 5
                                    self.viewControllers?.remove(at: index1)
                                }
                            }
                            
                        }
                        
                }
            }
//            if uid == "51IB2nwlWUVjuFBeqUlIRKngdKk1" {
//                        print("I am the admin")
//
//
//                    } else {
//                        print("im not the admin")
//                        let index1 = 1 //0 to 5
//                        viewControllers?.remove(at: index1)
//                    }
        }
        
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
