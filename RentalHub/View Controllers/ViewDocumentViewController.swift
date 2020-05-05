//
//  ViewDocumentViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 04/05/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit

class ViewDocumentViewController: UIViewController {

    @IBOutlet weak var fullSizeImageView: UIImageView!
    var image: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullSizeImageView.image = image
        
    }
    


}
