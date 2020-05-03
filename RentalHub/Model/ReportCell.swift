//
//  ReportCellTableViewCell.swift
//  RentalHub
//
//  Created by Ben Martin on 15/04/2020.
//  Copyright © 2020 Ben Martin. All rights reserved.
//

import UIKit

class ReportCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
