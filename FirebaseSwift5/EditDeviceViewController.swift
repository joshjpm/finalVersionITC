//
//  EditDeviceViewController.swift
//  FirebaseSwift5
//
//  Created by Wei Lian Chin on 09/09/2019.
//  Copyright © 2019 Wei Lian Chin. All rights reserved.
//

import UIKit

class EditDeviceViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
  
    
    @IBOutlet weak var modalTitle: UILabel!
    @IBOutlet weak var id_field: UITextField!
    @IBOutlet weak var device_field: UITextField!
    @IBOutlet weak var modeltype: UITextField!
    @IBOutlet weak var colortype: UITextField!
    var currentTextField = UITextField()
    var pickerView = UIPickerView()
    var model_list = [String]()
    var color_list = [String]()
    var newid = ""
    var newname = ""
    var newmodel = ""
    var newcolor =  ""
    var edititem :Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model_list = ["-----Please select a model-----","Iphone 6","Iphone 6 Plus","Iphone 6S","Iphone 6S Plus","Iphone SE","Iphone 7","Iphone 7 Plus","Iphone 8","Iphone 8 Plus","Iphone X","Iphone XS","Iphone XS Max","Iphone XR","Iphone X","Iphone 11","Iphone 11 Pro","Iphone 11 Pro Max","IPAD 4th generation", "IPAD 5th generation","IPAD 6th generation","IPAD MINI","IPAD PRO", "IPAD AIR"]
        color_list = ["-----Please select a color-----","Black","Blue","Coral","Gold","Red", "Rose Gold","Silver","Space Gray","White","Yellow"]
        
        if edititem {
            modalTitle.text = "Edit device"
        }else{
            modalTitle.text = "Add device"
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func confirmIsPressed(_ sender: Any) {
        self.newid = id_field.text!
        self.newname = device_field.text!
        if id_field.text! == "" || device_field.text! == "" || modeltype.text! == "" || colortype.text! == ""{
            alertpopup()
        }
        else{
        
            NotificationCenter.default.post(name: .newDevice, object: self )
            dismiss (animated:true)
            
        }
    }
    
    @IBAction func cancelIsPressed(_ sender: Any) {
        dismiss(animated: true)

    }
    func alertpopup(){
        
        let message = "Asterisk field cannot be blank. Please make sure you have fill in all the details"
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true)
    }
    func createtoolBar(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(EditDeviceViewController.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        currentTextField.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextField == modeltype{
            return model_list.count
        }else if currentTextField == colortype{
            return color_list.count
        }else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == modeltype{
            return model_list[row]
        }else if currentTextField == colortype{
            return color_list[row]
            
        }else{
            return ""
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if currentTextField == modeltype{
            modeltype.text = model_list[row]
            newmodel = modeltype.text!
            if newmodel == "-----Please select a model-----"{
                            modeltype.text = ""
                           newmodel = ""
                       }
            
        }else if currentTextField == colortype{
            colortype.text = color_list[row]
            newcolor = colortype.text!
            if newcolor == "-----Please select a color-----"{
                colortype.text = ""
                newcolor = ""
            }
            
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        currentTextField = textField
        if currentTextField == modeltype{
            currentTextField.inputView = pickerView
            createtoolBar()
        }else if currentTextField == colortype{
            currentTextField.inputView = pickerView
            createtoolBar()
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
