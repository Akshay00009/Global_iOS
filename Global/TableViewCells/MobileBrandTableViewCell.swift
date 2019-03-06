//
//  MobileBrandTableViewCell.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import SwiftyJSON
protocol MobileBrandTableViewCellDelegate {
    func showCountText(count : String,indexPath : IndexPath, show : Bool)
}
class MobileBrandTableViewCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var brandName: UILabel!
    
    @IBOutlet weak var stockLevel: UILabel!
    @IBOutlet weak var countTxtField: UITextField!
    var delegateObject : MobileBrandTableViewCellDelegate? = nil
    var selectedIndexPath = IndexPath()
    override func awakeFromNib() {
        super.awakeFromNib()
        countTxtField.delegate = self

        // Initialization code
    }

    func  setCell(viewModel : MobileBrandTableViewCellModel, indexPath:IndexPath) {
        countTxtField.delegate = self
        if viewModel.stockQuantity == "0" {
             countTxtField.text = ""
        } else {
            countTxtField.text = viewModel.stockQuantity
        }
        stockLevel.text = viewModel.stock
        brandName.text = viewModel.brand
        selectedIndexPath = indexPath
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
            if Int(newString as String) ?? 0 > Int(stockLevel.text!) ?? 0 {
                textField.text = ""
                delegateObject?.showCountText(count: newString as String, indexPath: selectedIndexPath, show: false)
                return true
            } else {
                delegateObject?.showCountText(count: newString as String, indexPath: selectedIndexPath, show: true)
                return true
            }
        return false
    }

}

class MobileBrandTableViewCellModel {
    let sID, brandID, code, lat,shopname : String
    let long, brand, stock: String
    var stockQuantity : String

    init(mobListDict : NSDictionary,stockQuant : String = "0") {
        self.stockQuantity = stockQuant
        self.sID = mobListDict["s_id"] as? String  == nil ? "" :  mobListDict["s_id"] as! String
        self.brandID = mobListDict["brand_id"] as? String  == nil ? "" :  mobListDict["brand_id"] as! String
        self.code = mobListDict["code"] as? String  == nil ? "" :  mobListDict["code"] as! String
        self.lat = mobListDict["lat"] as? String  == nil ? "" :  mobListDict["lat"] as! String
        self.long = mobListDict["long"] as? String  == nil ? "" :  mobListDict["long"] as! String
        self.brand = mobListDict["brand"] as? String  == nil ? "" :  mobListDict["brand"] as! String
        self.stock = mobListDict["stock"] as? String  == nil ? "" :  mobListDict["stock"] as! String
        self.shopname =  mobListDict["shopname"] as? String == nil ? "NA" :  mobListDict["shopname"] as! String
    }
}
