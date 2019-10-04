//
//  LogVC.swift
//  FirebaseSwift5
//
//  Created by Joshua Mac Guinness on 31/8/19.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

var vSpinner : UIView?
class LogVC: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
   
    // MARK: - Initial Decleration

    @IBOutlet weak var myview: UICollectionView!
    var db : Firestore!
    var ref: DatabaseReference!
    var dateList = [String]()
    var clockindevice = [[String]]()
    var totaldevice = [String:[String]]()
    var mylogdate = [String]()
    var alllogdate = [String]()
    var celldevicenumber = [[String]]()
    var logcelldevicenumber = [[String]]()
    var logtotaldevice = [String:[String]]()
    let date = Date()
    let formatday = DateFormatter()
    let formatdate = DateFormatter()
    let formatter = DateFormatter()
    var document_list = [String]()
    var devicedocument = [String:Device]()
    var username : String = ""
    var isAdmin : Bool = false
    var doingmylog : Bool = true
    var failedlog = [String:[String:String]]()
    var successlog = [String:[String:String]]()
    var keylist = [String]()
    var showlog: Bool = false
    var counter = 0
    
    @IBOutlet weak var scsegment: UISegmentedControl!
    
    
    // MARK: - View Config

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.formatday.dateFormat = "dd-MM-yyyy"
        self.formatdate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.formatter.locale = Locale(identifier: "en_US_POSIX")
        self.formatter.dateFormat = "h:mm a"
        self.formatter.amSymbol = "AM"
        self.formatter.pmSymbol = "PM"
        db = Firestore.firestore()
        db.collection("Devices").getDocuments(){
        querySnapshot, error in
        if let error = error{
            print("\(error.localizedDescription)")
        }else{
            
            self.document_list = []
            for document in querySnapshot!.documents {
                self.document_list.append(document.documentID)
                
            }
            for x in self.document_list{
                self.db.collection("Devices").document(x).getDocument { (document, error) in
                if document!.data() != nil{
                    
                    self.devicedocument[x] = Device(dictionary: document!.data()!)
                    
                }
                }
            }
            
            }
        }
        
        ref = Database.database().reference()
        print("hi")
        if Auth.auth().currentUser != nil {
            let user = Auth.auth().currentUser
            if let user = user {
                
                db.collection("user").getDocuments(){
                querySnapshot, error in
                if let error = error{
                    print("\(error.localizedDescription)")
                }else{
                    for document in querySnapshot!.documents {

                        if document.data()["email"] as? String == user.email!{
                            
                            self.username = document.data()["username"] as! String
                            self.isAdmin = document.data()["admin"] as! Bool
                            if self.isAdmin{
                            self.scsegment.setEnabled(true, forSegmentAt: 1)
                            self.scsegment.setEnabled(true, forSegmentAt: 2)
                            }
                            else{
                               self.scsegment.setEnabled(false, forSegmentAt: 1)
                                self.scsegment.setEnabled(false, forSegmentAt: 2)
                            }
                            self.loadData()
                            

                            }
            
                    }
                }
            }
        }
        }

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        // load pdf into webView
        self.tabBarController?.navigationItem.title = "Log"
        

        
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if counter == 1 {
            loadData()
        }
        
    }
    
    // MARK: - Data Formating
    func sortdate(x:[String])->[String]{
         var convertedArray: [Date] = []
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "dd-MM-yyyy"// yyyy-MM-dd"
         
         
         for dat in x{
             let date = dateFormatter.date(from: dat)
            
             if let date = date  {
                 convertedArray.append(date)
             }
             
         }

         let ready = convertedArray.sorted(by: { $0.compare($1) == .orderedDescending })
        
         var sorted_date = [String]()
         for x in ready {
             let newdate = dateFormatter.string(from: x)
             sorted_date.append(newdate)
         }
         return sorted_date

    }
    
    // MARK: - Request log

    
    func loadalllog(){
         self.showSpinner(onView: self.view)
        self.myview.isHidden = true
        var username_list = [String]()
        username_list.removeAll()
        self.logcelldevicenumber.removeAll()
        self.dateList.removeAll()
        self.logtotaldevice.removeAll()
        print(self.alllogdate)
        for date in self.alllogdate{
        self.ref.child("logs").child("mylog").child(date).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil {
                for (key,value) in value!{
                    let k = key as! String
                    if username_list.contains(k){}
                    else{
                        username_list.append(k)
                    }
                }
            
            for user in username_list{
   self.ref.child("logs").child("mylog").child(date).child(user).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil {
                    let x = value!.allKeys as! [String]
                    
                    for v in value!{
                        self.dateList.append(v.key as! String)
                    }
                    var array_details = [String]()
                    for newdate in self.dateList{
            self.ref.child("logs").child("mylog").child(date).child(user).child(newdate).observeSingleEvent(of: .value, with: {(snapshot)in
                            let value = snapshot.value as? NSDictionary
                            if value != nil{
                                for (k,v) in value!{
                                    let key = k as! String
            self.ref.child("logs").child("mylog").child(date).child(user).child(newdate).child(key).observeSingleEvent(of: .value, with: {(snapshot)in
                let value = snapshot.value as? NSDictionary
                if value != nil {
                    let clockin = value!["clockin"] as! String
                    let clockout = value!["clockout"] as! String
                    array_details.append(newdate)
                    array_details.append(key)
                    array_details.append(clockin)
                    array_details.append(clockout)
                    array_details.append(user)
                    
                    let result = String(newdate.prefix(10))
                    let year = result.prefix(4)
                    let month = result.suffix(5).prefix(2)
                    let day = result.suffix(2)
                    let newday = day + "-" + month + "-" + year
                    
                    if self.logtotaldevice[newday] == nil {
                        self.logtotaldevice[newday] = array_details
                    }
                    else{
                        self.logtotaldevice[newday]?.append(contentsOf:array_details)
                    }
                    array_details.removeAll()
                }
                                        
                                    })
                                }
                            }
                        })
                    }
    }
   })
            
            }
            }})
    }
        var timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {
            (_) in
            self.removeSpinner()
            self.myview.isHidden = false
            self.myview.reloadData()
         
        }
    }
 
    // MARK: - DB Data Pull Request

    func loadData(){
        getlog()
        self.showSpinner(onView: self.view)
        self.myview.isHidden = true
        self.totaldevice.removeAll()
        self.celldevicenumber.removeAll()
        self.dateList.removeAll()
        self.clockindevice.removeAll()
        self.mylogdate.removeAll()
        self.alllogdate.removeAll()
        
       
        self.ref.child("logs").child("mylog").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil {
                self.checkmylog(x: value!.allKeys)
                self.alllogdate = value!.allKeys as! [String]
            }
            
        })
        var getitem = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) {
        (_) in
            self.getdevice()
        }
        
        var timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) {
           (_) in
        
        self.removeSpinner()
            self.myview.isHidden = false
            

        print(self.failedlog)
        self.failedlog.merge(self.successlog) {(_,new) in new}
            print(self.successlog)
            
        for (k,v) in self.failedlog{
            print(k)
            self.keylist.append(k)
            
            }
            self.counter = 1
        self.myview.reloadData()
       }

    }
    
    func checkmylog(x :[Any]){
        for date in x{
            
            self.ref.child("logs").child("mylog").child(date as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil {
                    let x = value!.allKeys as! [String]
                    
                    if x.contains(self.username){
                        self.mylogdate.append(date as! String)
                    }
                    
                }
            })
            
        }
        
        
    }
    
    func getdevice (){
    
        var counter = 0
        for date in self.mylogdate{
            
            counter = counter + 1
            
        self.ref.child("logs").child("mylog").child(date).child(self.username).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if value != nil {
                    let x = value!.allKeys as! [String]
                    self.dateList = self.dateList + x
                    var array_details = [String]()
                    var previous_array = [[String]]()
                    
            for newdate in self.dateList{
                        
        self.ref.child("logs").child("mylog").child(date).child(self.username).child(newdate).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    if value != nil{
                                     
                        for (k,v) in value!{
                            let key = k as! String
        self.ref.child("logs").child("mylog").child(date).child(self.username).child(newdate).child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                                                           
                    let value = snapshot.value as? NSDictionary
                        if value != nil{
                            
                            let clockin = value!["clockin"] as! String
                            let clockout = value!["clockout"] as! String
                            array_details.append(newdate)
                            array_details.append(key)
                            array_details.append(clockin)
                            array_details.append(clockout)
                            
                            let result = String(newdate.prefix(10))
                            let year = result.prefix(4)
                            let month = result.suffix(5).prefix(2)
                            let day = result.suffix(2)
                            let newday = day + "-" + month + "-" + year
                            
                            
                            if previous_array.contains(array_details){
                                
                            }
                            else{
                            previous_array.append(array_details)
                            if self.totaldevice[newday] == nil{
                                self.totaldevice[newday] = array_details
                                }
                                    else{
                                    self.totaldevice[newday]?.append(contentsOf: array_details)
                                    }
                            }
                            array_details.removeAll()
                                    
                        }
                    })
                        }
            }
                        })
                    }
                    
            }
            
        })
            
                                   
            
        }
    }

    // MARK: - Log Functions

    func getlog(){
        var fkeylist = [String]()
        var skeylist = [String]()
        fkeylist.removeAll()
        skeylist.removeAll()
       
        self.ref.child("logs").child("login_attempts").child("pass").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            
            if value != nil {
                skeylist = value?.allKeys as! [String]
                
                for key in skeylist{
        self.ref.child("logs").child("login_attempts").child("pass").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil{
                self.successlog[key] = value! as! [String : String]

            }
                    })
                }
            }
        })
        self.ref.child("logs").child("login_attempts").child("failed").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil {
                fkeylist = value?.allKeys as! [String]
                for key in fkeylist{
        self.ref.child("logs").child("login_attempts").child("failed").child(key).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            if value != nil{
                self.failedlog[key] = value! as! [String : String]

            }
                    })
                }
            }
        })
       
    
        
        
        
    }
    // MARK: - Collection View Config

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var resuable : UICollectionReusableView? = nil
        if (kind == UICollectionView.elementKindSectionHeader){
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ReuseView", for: indexPath)as! ReusableView
            if showlog{
                view.LogHeaderTitle.text = "Login Attempts"
                resuable = view
                return resuable!
            }
            else{
            if doingmylog{
            mylogdate = self.sortdate(x: mylogdate)
            view.LogHeaderTitle.text = mylogdate[indexPath.section]
            resuable = view
            return resuable!
            }
            else{
                alllogdate = self.sortdate(x: alllogdate)
                view.LogHeaderTitle.text = alllogdate[indexPath.section]
                resuable = view
                return resuable!
            }
        }
        }
        return resuable!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if showlog{
            
            return 1
            
        }
        else{
        if doingmylog{
            mylogdate = self.sortdate(x: mylogdate)
            return mylogdate.count
        }
        else{
            alllogdate = self.sortdate(x: alllogdate)
            return alllogdate.count
        }
    }
    }
    
    
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
    if showlog{
        print(self.keylist)
        return self.keylist.count
    }
    else{
    if doingmylog{
        let item_number = totaldevice[mylogdate[section]]
        if item_number?.count != 0 && item_number != nil{
        return item_number!.count/4
        }
        else{
            return 0
        }
    }
    else{
        let item_number = logtotaldevice[alllogdate[section]]
        if item_number?.count != 0 && item_number != nil{
        return item_number!.count/5
        }
        else{
            return 0
        }
    }
       }
    }
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)as! LogViewCell
        if showlog{
            if keylist != [] && failedlog != [:]{
            let newlist = keylist.sorted{ $0 > $1 }
            let key = newlist[indexPath.row]
            let item = failedlog[key]
            
            cell.id.text = ""
            cell.name.text = ""
                cell.LogInDescription.text = item!["message"]
            cell.model.text = ""
            cell.clockIn.text = ""
            cell.clockout.text = ""
            cell.usedby.text = ""
            }
        }
        else{
        if doingmylog{
        let date = mylogdate[indexPath.section]
        var list = totaldevice[date]
        let index = indexPath.row * 4
        if list != nil {
            list?.removeFirst(index)
            let device = devicedocument[list![1]]
            cell.id.text = device?.id
            cell.name.text = device?.name
            cell.model.text = device?.model
            cell.clockIn.text = "Clock in at \(list![2])"
            cell.clockout.text = "Clock out at \(list![3])"
            cell.usedby.isHidden = true
            cell.usedby.text = ""
            cell.LogInDescription.text = ""
        }
        }
        else{
            let date = alllogdate[indexPath.section]
            var list = logtotaldevice[date]
            let index = indexPath.row * 5
            if list != nil {
                list?.removeFirst(index)
                let device = devicedocument[list![1]]
                cell.id.text = device?.id
                cell.LogInDescription.text = ""
                cell.name.text = device?.name
                cell.model.text = device?.model
                cell.clockIn.text = "Clock in at \(list![2])"
                cell.clockout.text = "Clock out at \(list![3])"
                cell.usedby.isHidden = false
                cell.usedby.text = "Used by \(list![4])"
            }
        }
        }
        
        
        
        //cell styling
    
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
    
    // MARK: - Cell interaction

    @IBAction func segmentgetTapped(_ sender: Any) {
        let getIndex = scsegment.selectedSegmentIndex
        
        switch (getIndex) {
        case 0:
            print ("hi")
            showlog = false
            myview.isHidden = false
            doingmylog = true
            loadData()
        case 1:
            print("all logs")
            showlog = false
            myview.isHidden = false
            doingmylog = false
            loadalllog()
        case 2:
            print("show all log")
            showlog = true
            self.myview.reloadData()
        default:
            print("hi")
        }
    }

    
    

}

// MARK: - Activity Monitoring

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
