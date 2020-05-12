//
//  SignDocumentViewController.swift
//  RentalHub
//
//  Created by Ben Martin on 11/05/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit

class SignedDocumentViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewDocumentButton: UIButton!
    @IBOutlet weak var mainDocumentTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    var document = Document()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        titleLabel.text = document.title
        if document.imageURL != nil {
            if let fileUrl = document.imageURL {
                let url = URL(string: fileUrl)
                URLSession.shared.dataTask(with: url!) { (data, response, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    DispatchQueue.main.async {
                        self.document.image = UIImage(data: data!)
                        self.imageView.image = UIImage(data: data!)
                    }
                }.resume()
            }
        }
        mainDocumentTextView.text = document.mainDocument
        dateLabel.text = document.date
        notesTextView.text = document.notes
        
        if document.mainDocument != "" {
            mainDocumentTextView.isHidden = false
            viewDocumentButton.isHidden = true
        }
        else if document.imageURL != "" {
            imageView.isHidden = false
        }
        
    }
    
    @IBAction func viewButtonTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "showSignedImage", sender: self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? ViewDocumentViewController {
            destination.image = document.image
            
        }
    }
}
