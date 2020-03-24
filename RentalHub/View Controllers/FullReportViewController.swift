//
//  FullReportViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 23/03/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit

class FullReportViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    var titleText : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleText
    }
}
