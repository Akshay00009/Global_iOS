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
    func showCountText(count : String,indexPath : IndexPath)
}
class MobileBrandTableViewCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var countTxtField: UITextField!
    var delegateObject : MobileBrandTableViewCellDelegate? = nil
    var indexPath = IndexPath()
    override func awakeFromNib() {
        super.awakeFromNib()
        countTxtField.delegate = self

        // Initialization code
    }

    func setupCell(dict : NSDictionary, index : IndexPath) {
        countTxtField.delegate = self
        indexPath = index
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString

        if Int(newString as String)! > 10 {
            textField.text = ""
            delegateObject?.showCountText(count: countTxtField.text!, indexPath: indexPath)
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}

class MobileBrandTableViewCellModel {
    let sID, brandID, code, lat: String
    let long, brand, stock: String

    init(mobListDict : JSON) {
        self.sID = mobListDict["s_id"].string == nil ? "" :  mobListDict["s_id"].string!
        self.brandID = mobListDict["brand_id"].string == nil ? "" :  mobListDict["brand_id"].string!
        self.code = mobListDict["code"].string == nil ? "" :  mobListDict["code"].string!
        self.lat = mobListDict["lat"].string == nil ? "" :  mobListDict["lat"].string!
        self.long = mobListDict["long"].string == nil ? "" :  mobListDict["long"].string!
        self.brand = mobListDict["brand"].string == nil ? "" :  mobListDict["brand"].string!
        self.stock = mobListDict["stock"].string == nil ? "" :  mobListDict["stock"].string!

    }
}
