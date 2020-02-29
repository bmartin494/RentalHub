//
//  ReportViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 26/02/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {

    @IBOutlet weak var issuePickerTextField: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var riskSwitch: UISwitch!
    @IBOutlet weak var warningLabel: UILabel!
    
    let issues = ["Electrical",
                  "Plumbing",
                  "Kitchen Appliances",
                  "Heating",
                  "Security",
                  "Other"]
    
    var selectedIssue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createIssuePicker()
        createToolbar()
        riskSwitch.addTarget(self, action: #selector(ReportViewController.switchIsChanged(riskSwitch:)), for: UIControl.Event.valueChanged)

    }
    

    func createIssuePicker() {
        let issuePicker = UIPickerView()
        issuePicker.delegate = self
        
        issuePickerTextField.inputView = issuePicker
    }
    
    func createToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ReportViewController.dismissKeyboard))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        issuePickerTextField.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @objc func switchIsChanged(riskSwitch: UISwitch) {
        if riskSwitch.isOn {
            warningLabel.alpha = 1
        } else {
            warningLabel.alpha = 0
        }
    }
    @IBAction func submitBtnTapped(_ sender: Any) {
        
        
    }
    
    
}


extension ReportViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return issues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return issues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIssue = issues[row]
        issuePickerTextField.text = selectedIssue
    }
}
