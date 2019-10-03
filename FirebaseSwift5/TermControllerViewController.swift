//
//  TermControllerViewController.swift
//  FirebaseSwift5
//
//  Created by Wei Lian Chin on 28/08/2019.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import UIKit
import WebKit
import FirebaseAuth
class TermControllerViewController: UIViewController {

    @IBOutlet weak var webview: WKWebView!
    
    override func viewDidAppear(_ animated: Bool) {
        // load pdf into webView
        self.tabBarController?.navigationItem.title = "Term & Condition"
        let path = Bundle.main.path(forResource: "TermsAndCond", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        let request = URLRequest(url: url)
        webview.load(request)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
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
    
}
