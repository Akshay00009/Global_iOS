//
//  ReportTableViewCell.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import SwiftyJSON

class ReportTableViewCell: UITableViewCell {
    @IBOutlet weak var brandName: UILabel!
    
    @IBOutlet weak var purchaseOrder: UILabel!
    @IBOutlet weak var stockLevel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func  setCell(viewModel : ReportTableViewCellCellModel, indexPath:IndexPath) {
        
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class ReportTableViewCellCellModel {
    init(reportListDict : NSDictionary) {
        
    }
}
