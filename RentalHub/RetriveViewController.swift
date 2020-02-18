//
//  RetriveViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 08/01/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RetriveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    @IBOutlet weak var tableView: UITableView!
    var postData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        databaseHandle = ref?.child("users").observe(.childAdded, with: { (snapshot) in
            
            let post = snapshot.value as? String
            
            if let actualPost = post {
            self.postData.append(actualPost)
                self.tableView.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell")
        cell?.textLabel?.text = postData[indexPath.row]
        
        return cell!
    }
    
    @IBAction func refreshBtn(_ sender: Any) {
    }
    
    @IBAction func backBtn(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
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
