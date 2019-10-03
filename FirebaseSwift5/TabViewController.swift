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
                    }
                    else{
                        let index1 = 1 //0 to 5
                        self.viewControllers?.remove(at: index1)
                    }
                }
                
            }
            
    }
            }

        }
        
    }
    


}
