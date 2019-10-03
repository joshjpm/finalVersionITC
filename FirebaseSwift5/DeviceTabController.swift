//
//  HomeViewController.swift
//  FirebaseSwift5
//
//  Created by Wei Lian Chin on 27/08/2019.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

class DeviceTabController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
//    var id_list = [String]()
//    var name_list = [String]()
//    var user_list = [String]()
    
//    var refresh = 1
//    //sample data
//    var id_list = ["1","2","3","1","2","3","1","2","3"]
//    var name_list = ["dog","cat","cow","1","2","3","1","2","3"]
//    var user_list = ["richard", "john", "Ian","1","2","3","1","2","3"]
    
    @IBOutlet weak var myview: UICollectionView!
    var db : Firestore!
    var ref: DatabaseReference!
    var devicelist = [Device]()
    var document_list = [String]()
    var uid = ""
    var email = ""
    var arrSections = ["Active Devices", "Available Devices", "Other Devices"]
    var arrayActive =  [Device]()
    var arrayAvailable =  [Device]()
    var arrayOther =  [Device]()
    var arrayCombine : NSMutableArray!
    var observer : NSObjectProtocol?
    var document_for_active = [String]()
    var document_for_available = [String]()
    var document_for_other = [String]()
    var username : String = ""
    let date = Date()
    let formatday = DateFormatter()
    let formatdate = DateFormatter()
    let formatter = DateFormatter()
    var dateList = [String]()
    var counter = 0
    override func viewDidLoad() {
        
        super.viewDidLoad()
        db = Firestore.firestore()
        ref = Database.database().reference()
        
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                
                uid = user.uid
                db.collection("user").getDocuments(){
                querySnapshot, error in
                if let error = error{
                    print("\(error.localizedDescription)")
                }else{
                    for document in querySnapshot!.documents {

                        if document.data()["email"] as? String == user.email!{
                            
                            self.username = document.data()["username"] as! String
                            self.loadData()
                            

                            }
            
                    }
                }
            }
        }
        }
        
        arrayCombine = NSMutableArray(array:[arrayActive, arrayAvailable,arrayOther])
        //periodically (half an hour) refresh the data to make sure the data is up to date
        
        
        var timer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) {
            (_) in
            self.loadData()
            print("Screen refreshed")
        }
        
        // Do any additional setup after loading the view.
    }
    func loadData(){
        getlogdevice()
        getdevicelist()
        
    }
    
   
    
    func getdevicelist(){
        db.collection("Devices").getDocuments(){
            querySnapshot, error in
            if let error = error{
                print("\(error.localizedDescription)")
            }else{
                
                self.document_list = []
                for document in querySnapshot!.documents {
                    self.document_list.append(document.documentID)
                    
                }
                
                self.devicelist = querySnapshot!.documents.compactMap({Device(dictionary: $0.data())})
                
                var array_for_other = [Device]()
                var array_for_active = [Device]()
                var array_for_available = [Device]()
                self.document_for_active = []
                self.document_for_available = []
                self.document_for_other = []
                var counter = 0
                for device in self.devicelist{
                    
                    if device.used == false {
                        array_for_available.append(device)
                        self.document_for_available.append(self.document_list[counter])
                        counter = counter + 1
                    }
                    else{
                        if device.activatedBy == self.uid{
                            array_for_active.append(device)
                            self.document_for_active.append(self.document_list[counter])
                            counter = counter + 1
                        }
                        else{
                            array_for_other.append(device)
                            self.document_for_other.append(self.document_list[counter])
                            counter = counter + 1
                        }
                    }
                }
                self.arrayAvailable = array_for_available
                self.arrayActive = array_for_active
                self.arrayOther = array_for_other
                array_for_available.removeAll()
                array_for_active.removeAll()
                array_for_other.removeAll()
                
                self.arrayCombine = NSMutableArray(array:[self.arrayActive, self.arrayAvailable,self.arrayOther])
                
                                DispatchQueue.main.async {
                                    
                                    self.myview.reloadData()
                                    self.counter = 1
                                }
            
                           
                           }
        }
    }
     
    func getlogdevice(){
    
    self.formatday.dateFormat = "dd-MM-yyyy"
      self.formatdate.dateFormat = "yyyy-MM-dd HH:mm:ss"
         self.formatter.locale = Locale(identifier: "en_US_POSIX")
         self.formatter.dateFormat = "h:mm a"
         self.formatter.amSymbol = "AM"
         self.formatter.pmSymbol = "PM"
         let today = self.formatday.string(from: Date())
         self.dateList.removeAll()
        
         
         
         self.ref.child("logs").child("mylog").child(today).child(self.username).observeSingleEvent(of: .value, with: { (snapshot) in
                            // Get user value
                        
             let value = snapshot.value as? NSDictionary
                 if value != nil {
                    
                     for v in value!{
                                
                         self.dateList.append (v.key as! String)
                        
                     }
                        
                         self.dateList.sort()
            }})
    }
               

            
    
   
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Devices"
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if counter == 1{
            loadData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func refreshButtonTouch(_ sender: Any) {
        loadData()
        
    }
    
    @IBAction func addDevice(_ sender: Any){
        if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
            
            self.performSegue(withIdentifier: "goModal2", sender: self)
            observer = NotificationCenter.default.addObserver(forName: .newDevice, object: nil, queue: OperationQueue.main){ (notication) in
               let newdata = notication.object as! EditDeviceViewController
                let newDevice = Device(id : newdata.newid, name: newdata.newname,model: newdata.newmodel,color: newdata.newcolor , timeStamp: Timestamp(),used: false, activatedBy: "", usingBy: "")
                var ref:DocumentReference? = nil

                ref = self.db.collection("Devices").addDocument(data: newDevice.dictionary){
                    error in

                    if let error = error {
                        print("Error occurs: \(error.localizedDescription)")
                    }else{
                        print("Document added sucessfully with ID: \(ref!.documentID)")
                    }
                    self.loadData()
                }
        }
    }

        
        
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var resuable : UICollectionReusableView? = nil
        if (kind == UICollectionView.elementKindSectionHeader){
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ReusableView", for: indexPath)as! ReusableView
            view.HeaderTitle.text = arrSections[indexPath.section]
            resuable = view
            return resuable!
        }
        return resuable!
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return arrSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (arrayCombine.object(at: section)as! NSArray).count
        //return devicelist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)as! CollectionViewCell
        if indexPath.section == 0{
            let device = arrayActive[indexPath.row]

            cell.id.text = device.id
            cell.name.text = device.name
            cell.user.text = device.model
            cell.clockin.isHidden = true
            cell.clockout.isHidden = false
            cell.clockout.setTitle("Clock out", for: .normal)
            cell.index = indexPath
            cell.delegate = self
            cell.clockIn.isHidden = true
            cell.clockOut.isHidden = true
            
        }
            else if indexPath.section == 1{
                let device = arrayAvailable[indexPath.row]
                            
                            
            cell.id.text = device.id
            cell.name.text = device.name
            cell.user.text = device.model
            cell.clockin.isHidden = false
            cell.clockout.isHidden = true
            cell.clockout.setTitle("Clock out", for: .normal)
            cell.index = indexPath
            cell.delegate = self
            cell.clockIn.isHidden = true
            cell.clockOut.isHidden = true
                
            }
        else if indexPath.section == 2{
            let device = arrayOther[indexPath.row]
                        
                        
            cell.id.text = device.id
            cell.name.text = device.name
            cell.user.text = "Using By : \(device.usingBy)"
            cell.clockin.isHidden = true
            cell.clockout.isHidden = false
            
            if username == "admin" {
                cell.clockout.setTitle("Force clockout", for: .normal)
            } else {
                cell.clockout.setTitle("", for: .normal)
            }
            
            cell.index = indexPath
            cell.delegate = self
            cell.clockIn.isHidden = true
            cell.clockOut.isHidden = true
        }
        
        
        // MARK: - Cell Styling
        
        //if want image "cell.xx.image = xx[indexPath.row]
//        cell.contentView.layer.cornerRadius = 10
//        cell.contentView.layer.borderWidth = 1.0
//        cell.contentView.layer.borderColor = UIColor.clear.cgColor
//        cell.contentView.layer.masksToBounds = false
//        cell.layer.shadowColor = UIColor.gray.cgColor
//        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
//        cell.layer.shadowRadius = 4.0
//        cell.layer.shadowOpacity = 1.0
//        cell.layer.masksToBounds = false
//        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        
        
        cell.contentView.backgroundColor = .white
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
        
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowRadius = cell.contentView.layer.cornerRadius
        
        
        return cell
    }

    @IBAction func logOutButtonTouch(_ sender: Any) {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goModal"{
            let popup = segue.destination as! EditDeviceViewController
            popup.edititem = true
        }else if segue.identifier == "goModal2"{
            let popup = segue.destination as! EditDeviceViewController
            popup.edititem = false
        }
        
    }
    
}

extension DeviceTabController: DataCollectionProtocol{
    
    
    func editData(indx: Int, sec :Int) {
        
        var list = [String]()
        if sec == 0{
            list = self.document_for_active
        }
        else if sec == 1{
            list = self.document_for_available
        }
        else if sec == 2 {
            list = self.document_for_other
        }
        
        
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        self.performSegue(withIdentifier: "goModal", sender: self)
        observer = NotificationCenter.default.addObserver(forName: .newDevice, object: nil, queue: OperationQueue.main){ (notication) in
            let newdata = notication.object as! EditDeviceViewController
            self.db.collection("Devices").document(list[indx]).updateData([
                "id": newdata.newid,
                "name": newdata.newname,
                "model": newdata.newmodel,
                "color": newdata.newcolor

            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
            
        }
        
    
        self.loadData()
    }
    
    func deleteData(indx: Int, sec :Int) {
        var list = [String]()
        if sec == 0{
            list = self.document_for_active
        }
        else if sec == 1{
            list = self.document_for_available
        }
        else if sec == 2 {
            list = self.document_for_other
        }
        
        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.db.collection("Devices").document(list[indx]).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
           
        }
    
        dialogMessage.addAction(yes)
        dialogMessage.addAction(cancel)

        self.present(dialogMessage, animated: true, completion: nil)
        

    }
    func clockin(indx: Int, sec :Int) {
       let date = Date()
        let formatday = DateFormatter()
        let formatdate = DateFormatter()
        let formatter = DateFormatter()

        formatday.dateFormat = "dd-MM-yyyy"
        
        formatdate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let today = formatday.string(from: date)
        let formattedDate = formatdate.string(from: date)
        let now = formatter.string(from: date)
        let devicename = self.document_for_available[indx]
        
        self.db.collection("Devices").document(devicename).updateData([
            "used": true,
            "activatedBy": self.uid,
            "usingBy": self.username,

        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        self.ref.child("logs/mylog/\(today)/\(self.username)/\(formattedDate)/\(devicename)/clockin").setValue("\(now)")
        self.ref.child("logs/mylog/\(today)/\(self.username)/\(formattedDate)/\(devicename)/clockout").setValue("")
            
            
        self.loadData()
    }
    
    func clockout(indx: Int, sec: Int) {
        var list = [String]()
        if sec == 0{
            list = self.document_for_active
        }
        else if sec == 1{
            list = self.document_for_available
        }
        else if sec == 2 {
            list = self.document_for_other
        }
               let userID = uid
               
               let date = Date()
               let formatday = DateFormatter()
               let formatdate = DateFormatter()
               let formatter = DateFormatter()

               formatday.dateFormat = "dd-MM-yyyy"
               
               formatdate.dateFormat = "yyyy-MM-dd HH:mm:ss"
               
               formatter.locale = Locale(identifier: "en_US_POSIX")
               formatter.dateFormat = "h:mm a"
               formatter.amSymbol = "AM"
               formatter.pmSymbol = "PM"
               let today = formatday.string(from: date)
               let formattedDate = formatdate.string(from: date)
               let now = formatter.string(from: date)
              
               let devicename = list[indx]
               
               let alert = UIAlertController(title: "Enter Device Details Below to Clock Out Your Device", message: nil, preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               
               alert.addTextField(configurationHandler: { textField in
                   textField.placeholder = "Device Condition"
               })
               alert.addTextField(configurationHandler: { textField in
                   textField.placeholder = "Related Project"
               })
               
               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                   
                   if let condition = alert.textFields?.first?.text, let project = alert.textFields?.last?.text {
                       print("Condition: \(condition)")
                       print("Project: \(project)")
                       
                    
                      for date in self.dateList{
                       
                        self.ref.child("logs").child("mylog").child(today).child(self.username).child(date).child(devicename).observeSingleEvent(of: .value, with: { (snapshot) in
                          // Get user value
                            let value = snapshot.value as? [String : AnyObject] ?? [:]
                            if value["clockout"] == nil{
                                
                            }
                            else{
                            if value["clockout"] as! String == ""{
                            self.ref.child("logs/mylog/\(today)/\(self.username)/\(date)/\(devicename)/clockout").setValue("\(now)")
                            }
                            }
                      }){ (error) in
                          print(error.localizedDescription)
                      }
                    }
                       // Add a new document with a generated id.
                        self.db.collection("Devices").document(list[indx]).updateData([
                            "used": false,
                            "activatedBy": "",
                            "usingBy": "",

                        ]) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("Document successfully written!")
                            }
                        }
                       var ref: DocumentReference? = nil
                       ref = self.db.collection("logs").addDocument(data: [
                           "condition": condition,
                           "project": project,
                           "uid": userID,
                           "clockOut": formattedDate
                       ]) { err in
                           if let err = err {
                               print("Error adding document: \(err)")
                           } else {
                               print("Document added with ID: \(ref!.documentID)")
                           }
                       }
                       
                       
                   }

               }))
               
               self.present(alert, animated: true)
                
    }
}
 
