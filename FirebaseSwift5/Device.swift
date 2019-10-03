//
//  File.swift
//  FirebaseSwift5
//
//  Created by Wei Lian Chin on 06/09/2019.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import Foundation
import FirebaseFirestore

protocol DocumentSerializable{
    init?(dictionary:[String:Any])
}

struct Device {
    var id:String
    var name:String
    var model:String
    var color:String
    var timeStamp: Timestamp
    var used:Bool
    var activatedBy: String
    var usingBy: String
    var checkin: String
    var dictionary:[String:Any]
    {
        return [
            "id":id,
            "name":name,
            "model":model,
            "color":color,
            "timeStamp":timeStamp,
            "used":used,
            "activatedBy": activatedBy,
            "usingBy": usingBy,
            "checkin": checkin
        ]
    }
}

extension Device : DocumentSerializable{
    init?(dictionary:[String:Any]){
        guard let id = dictionary["id"] as? String,
            let name = dictionary["name"]as? String,
            let model = dictionary["model"]as? String,
            let color = dictionary["color"]as? String,
            let timeStamp = dictionary["timeStamp"] as? Timestamp ,
            let used = dictionary["used"] as? Bool ,
            let activatedBy = dictionary["activatedBy"] as? String,
            let usingBy = dictionary["usingBy"] as? String,
            let checkin = dictionary["checkin"] as? String else {
                return nil
        }
        self.init(id: id, name: name, model: model, color:color, timeStamp: timeStamp, used: used, activatedBy : activatedBy, usingBy:usingBy, checkin:checkin)
    }
}

