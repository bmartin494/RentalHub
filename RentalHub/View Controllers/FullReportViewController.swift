//
//  FullReportViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 23/03/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit

class FullReportViewController: UIViewController {
    
    @IBOutlet weak var propertyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageTitleLabel: UILabel!
    @IBOutlet weak var reportImageView: UIImageView!
    @IBOutlet weak var issueLabel: UILabel!
    
    var propertyText: String!
    var dateText: String!
    var issueText: String!
    var descriptionText: String!
    var imageURL: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        propertyLabel.text = propertyText
        dateLabel.text = dateText
        issueLabel.text = issueText
        descriptionLabel.text = descriptionText
        
        if imageURL == nil {
            imageTitleLabel.text = "No image submitted with report"
        }
        else {
            imageTitleLabel.text = "Attached image"
            if let fileUrl = imageURL {
                let url = URL(string: fileUrl)
                URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    DispatchQueue.main.async {
                        self.reportImageView.image = UIImage(data: data!)
                    }
                }.resume()
            }
        }
    }
    
}
