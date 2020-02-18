//
//  SubmitViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 07/01/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SubmitViewController: UIViewController {

    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitData(_ sender: Any) {
        self.ref.child("users").childByAutoId().setValue(UITextView.text)
    }
    
    
    @IBAction func clearForm(_ sender: Any) {
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
