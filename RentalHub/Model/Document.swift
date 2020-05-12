//
//  Document.swift
//  RentalHub
//
//  Created by Ben Martin on 04/05/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit

class Document: NSObject {

    var documentID: String?
    var propertyID: String?
    var title: String?
    var mainDocument: String?
    var notes: String?
    var signatureRequired: Bool?
    var imageURL: String?
    var image: UIImage? = nil
    var date: String?
    var signatureCount: Int?
    var deleteCount: Int?
    var signatures = [String]()
}
