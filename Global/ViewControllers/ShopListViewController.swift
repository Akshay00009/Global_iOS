//
//  shopListViewController.swift
//  Global
//
//  Created by akshay Avati on 18/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class ShopListViewController: UIViewController,BCDropDownButtonDelegate,NVActivityIndicatorViewable {
    
    @IBOutlet weak var bcDropDownBtn: BCDropDownButton!
    @IBOutlet weak var shopListTableView: UITableView!
    var shopListArray = [ShopListTableViewCellModel]()
    var routeListArray = [AnyObject]()
    override func viewDidLoad() {
        super.viewDidLoad()
        shopListTableView.delegate = self
        shopListTableView.dataSource = self
        self.shopListTableView.register(UINib(nibName: "ShopListTableViewCell", bundle: nil), forCellReuseIdentifier: "ShopListTableViewCell")
        bcDropDownBtn.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        routeListApiCall()
    }
    
    func routeListApiCall() {
        let url = "http://globemobility.in/admin/Mobile/userlisting"
        let Parameter: [String : AnyObject] = ["user_id": 45 as AnyObject]
        NetworkHelper.shareWithPars(parameter: Parameter as NSDictionary,method: .post, url: url, completion: { (result) in
            self.stopAnimating()
            let response = result as NSDictionary
            let resultValue = response["Result"] as! String
            var array = [AnyObject]()
            if resultValue == "True" {
                let dataArray : NSArray = response["data"] as! NSArray
                for dict in dataArray {
                    let dic = dict as? NSDictionary
                    self.routeListArray.append(dic!)
                    array.append(dic?.value(forKey: "routname") as AnyObject)
                }
                array.insert("Select Route" as AnyObject, at:0)
                self.bcDropDownBtn.items = array
            }
        }, completionError:  { (error) in
            self.stopAnimating()
            let errorResponse = error as NSDictionary
            if errorResponse.value(forKey: "errorType") as! NSNumber == 1 {
                self.present(AppUtility.showInternetErrorMessage(title: "", errorMessage: kNoInterNetMessage, completion: {
                }), animated: true, completion: nil)
            }  else if errorResponse.value(forKey: "errorType") as! NSNumber == 2 || errorResponse.value(forKey: "errorType") as! NSNumber == 3 {
                self.showAlert(message: kSomethingGetWrong, Title: "Error")
            }
        })
        
    }
    
    
    func shopListApiCall(routeId : String) {
        startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
        let url = "http://globemobility.in/admin/Mobile/getShopList"
        let Parameter: [String : AnyObject] = ["Route_id": routeId as AnyObject]
        NetworkHelper.shareWithPars(parameter: Parameter as NSDictionary,method: .post, url: url, completion: { (result) in
            self.stopAnimating()
            let response = result as NSDictionary
            let resultValue = response["Result"] as! String
            if resultValue == "True" {
                let dataArray : NSArray = response["data"] as! NSArray
                for dict in dataArray {
                    self.shopListArray.append(ShopListTableViewCellModel(shopListDict: dict as! NSDictionary))
                }
                self.shopListTableView.reloadData()
            }
        }, completionError:  { (error) in
            self.stopAnimating()
            let errorResponse = error as NSDictionary
            if errorResponse.value(forKey: "errorType") as! NSNumber == 1 {
                self.present(AppUtility.showInternetErrorMessage(title: "", errorMessage: kNoInterNetMessage, completion: {
                }), animated: true, completion: nil)
            }  else if errorResponse.value(forKey: "errorType") as! NSNumber == 2 || errorResponse.value(forKey: "errorType") as! NSNumber == 3 {
                self.showAlert(message: kSomethingGetWrong, Title: "Error")
            }
        })
        
    }
    
    func  showAlert(message: String = "", Title: String = "") {
        let alertController = UIAlertController(title: Title, message: message, preferredStyle: UIAlertController.Style.alert)
        let retryAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {
            alert -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(retryAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func dropDownButton(_ button: BCDropDownButton!, didChangeValue value: String!, with index: Int) {
        print(value,index)
        if index != 0 {
            let ind = index - 1
            let routeId = routeListArray[ind]["rout_id"]
            shopListApiCall(routeId : routeId as! String)
        }
    }
}
extension ShopListViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopListTableViewCell = shopListTableView.dequeueReusableCell(withIdentifier: "ShopListTableViewCell", for: indexPath) as! ShopListTableViewCell
         let shopdict = shopListArray[indexPath.row]
        cell.setCell(viewModel : shopdict , indexPath : indexPath)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let shopListVc = self.storyboard?.instantiateViewController(withIdentifier: "MobileBrandListViewController") as? MobileBrandListViewController
        self.navigationController?.pushViewController(shopListVc!, animated: true)

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//       let addressFrame = estimateFrameForText(text: shopListArray[indexPath.row].address)
//       let emailFrame = estimateFrameForText(text: shopListArray[indexPath.row].email)
//       let ownernameFrame = estimateFrameForText(text: shopListArray[indexPath.row].ownername)
//        let mobFrame = estimateFrameForText(text: shopListArray[indexPath.row].mob)
//
//        let height = 30 + emailFrame.height + addressFrame.height + ownernameFrame.height + mobFrame.height
        return 158//height

    }
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: self.view.frame.size.width - 108  , height: 10000000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        do {
            let attributedString = try NSMutableAttributedString(data: text.data(using: String.Encoding.utf8, allowLossyConversion: false)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue ],  documentAttributes: nil)
            attributedString.addAttributes([NSAttributedString.Key.font: UIFont.init(name: FontStyle.FontName.kDefault, size: 15.0)!], range: NSMakeRange(0, attributedString.length))
            return attributedString.boundingRect(with: size, options: options, context: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }

}
