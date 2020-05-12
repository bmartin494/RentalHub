//
//  Property.swift
//  RentalHub
//
//  Created by Ben Martin on 15/04/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit

class Property: NSObject {
    
    var address: String?
    var city: String?
    var county: String?
    var postcode: String?
    var landlordID: String?
    var landlordEmail: String?
    var propertyID: String?
    var dueDate: String?
    var rent: String?
    var signatures = [String]()
    var tenants = [String]()
    
}
