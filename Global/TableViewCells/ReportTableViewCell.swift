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
        brandName.text = viewModel.brand
        purchaseOrder.text = viewModel.currentQty
        stockLevel.text = viewModel.minQty
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class ReportTableViewCellCellModel {
    let brand, minQty, currentQty: String
    init(reportListDict : NSDictionary) {
        self.brand = reportListDict["brand"] as? String  == nil ? "" :  reportListDict["brand"] as! String
        self.minQty = reportListDict["min_qty"] as? String  == nil ? "" :  reportListDict["min_qty"] as! String
        self.currentQty = reportListDict["current_qty"] as? String  == nil ? "" : reportListDict["current_qty"] as! String
    }
}

