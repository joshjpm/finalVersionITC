//
//  FirebaseAuthManager.swift
//  BoringSSL-GRPC
//
//  Created by Joshua Mac Guinness on 31/8/19.
//

import UIKit
import Firebase


class FirebaseAuthManager {
    func createUser(email: String, password: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if let user = authResult?.user {
                print(user)
                completionBlock(true)
            } else {
                completionBlock(false)
            }
        }
    }
}
