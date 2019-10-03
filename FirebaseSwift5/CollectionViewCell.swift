//
//  CollectionViewCell.swift
//  FirebaseSwift5
//
//  Created by Wei Lian Chin on 29/08/2019.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import UIKit

protocol DataCollectionProtocol{
    func deleteData(indx: Int, sec: Int)
    func editData(indx: Int,sec: Int)
    func clockin(indx: Int,sec: Int)
    func clockout(indx: Int,sec: Int)
}
class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var clockIn: UILabel!
    @IBOutlet weak var clockOut: UILabel!
    
    @IBOutlet weak var editbutton: UIButton!
    @IBOutlet weak var removebutton: UIButton!
    @IBOutlet weak var clockin: UIButton!
    
    @IBOutlet weak var clockout: UIButton!
    
    var delegate: DataCollectionProtocol?
    var index: IndexPath?
    
    @IBAction func deleteButton(_ sender: Any) {
        delegate?.deleteData(indx: (index?.row)!, sec: (index?.section)!)
    }
    
    
    @IBAction func editButton(_ sender: Any) {
        delegate?.editData(indx: (index?.row)!,sec: (index?.section)!)
    }
    
    @IBAction func clockInButton(_ sender: Any) {
        delegate?.clockin(indx: (index?.row)!,sec: (index?.section)!)
    }
    
    @IBAction func clockOutButton(_ sender: Any) {
        delegate?.clockout(indx: (index?.row)!,sec: (index?.section)!)
    }
    
}
