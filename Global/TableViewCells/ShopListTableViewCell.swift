//
//  ShopListTableViewCell.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import SwiftyJSON
protocol shopInBtnTableViewCellDelegate {
    func shopIn(selectedIndexPath : IndexPath,buttonName : String)
    
}

class ShopListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var mobileNo: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    var delegateObject : shopInBtnTableViewCellDelegate? = nil
    var selectedindexPath = IndexPath()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func  setCell(viewModel : ShopListTableViewCellModel, indexPath:IndexPath) {
        selectedindexPath = indexPath
        address.text = viewModel.address
        mobileNo.text = viewModel.mob
        email.text = viewModel.email
        ownerName.text = viewModel.ownername
    }

    @IBAction func inBtnAction(_ sender: Any) {
        delegateObject?.shopIn(selectedIndexPath: selectedindexPath, buttonName: "in")
    }
    @IBAction func reportBtnAction(_ sender: Any) {
        delegateObject?.shopIn(selectedIndexPath: selectedindexPath, buttonName: "report")
    }
}

class ShopListTableViewCellModel {
    let shopID, routID, shopname, ownername: String
    let email, city, area, mob: String
    let address, lat, long: String
    
    init(shopListDict : NSDictionary) {
        self.shopID = shopListDict["shop_id"] as? String == nil ? "NA" :  shopListDict["shop_id"] as! String
        self.routID =  shopListDict["rout_id"] as? String == nil ? "NA" :  shopListDict["rout_id"] as! String
        self.shopname =  shopListDict["shopname"] as? String == nil ? "NA" :  shopListDict["shopname"] as! String
        self.ownername =  shopListDict["ownername"] as? String == nil ? "NA" :  shopListDict["ownername"] as! String
        self.email =  shopListDict["email"] as? String == nil ? "NA" :  shopListDict["email"] as! String
        self.city =  shopListDict["city"] as? String == nil ? "NA" :  shopListDict["city"] as! String
        self.area =  shopListDict["area"] as? String == nil ? "NA" :  shopListDict["area"] as! String
        self.mob =  shopListDict["mob"] as? String == nil ? "NA" :  shopListDict["mob"] as! String
        self.address =  shopListDict["address"] as? String == nil ? "NA" :  shopListDict["address"] as! String
        self.lat =  shopListDict["lat"] as? String == nil ? "NA" :  shopListDict["lat"] as! String
        self.long =  shopListDict["long"] as? String == nil ? "NA" :  shopListDict["long"] as! String
    }
}

