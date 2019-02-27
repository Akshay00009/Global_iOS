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
import CoreLocation

class ShopListViewController: UIViewController,BCDropDownButtonDelegate,NVActivityIndicatorViewable,CLLocationManagerDelegate {
    
    @IBOutlet weak var bcDropDownBtn: BCDropDownButton!
    @IBOutlet weak var shopListTableView: UITableView!
    var shopListArray = [ShopListTableViewCellModel]()
    var routeListArray = [AnyObject]()
    var userId = ""
    var longitudeValue = ""
    var latitudeValue = ""

    var currentLocation: CLLocation! = nil
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        shopListTableView.isHidden = true
        shopListTableView.delegate = self
        shopListTableView.dataSource = self
        self.shopListTableView.register(UINib(nibName: "ShopListTableViewCell", bundle: nil), forCellReuseIdentifier: "ShopListTableViewCell")
        bcDropDownBtn.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // For use when the app is open
        //locationManager.requestWhenInUseAuthorization()
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest // You can change the locaiton accuary here.
            locationManager.startUpdatingLocation()
            currentLocation = locationManager.location
        }
        

        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.longitude
            let long = location.coordinate.latitude
            let latValue = Double(String(format: "%.7f", lat))
            let longValue = Double(String(format: "%.7f", long))
        }
    }
    
    // If we have been deined access give the user the option to change it
    
    @available(iOS 4.2, *)
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        locationManager.startUpdatingLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        routeListApiCall()
    }
    
    func routeListApiCall() {
        let url = "http://globemobility.in/admin/Mobile/userlisting"
        let Parameter: [String : AnyObject] = ["user_id": userId as AnyObject]
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
                self.shopListTableView.isHidden = true
                self.present(AppUtility.showInternetErrorMessage(title: "", errorMessage: kNoInterNetMessage, completion: {
                    self.routeListApiCall()
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
                self.shopListArray.removeAll()
                let dataArray : NSArray = response["data"] as! NSArray
                for dict in dataArray {
                    self.shopListArray.append(ShopListTableViewCellModel(shopListDict: dict as! NSDictionary))
                }
                self.shopListTableView.isHidden = false
                self.shopListTableView.reloadData()
            } else {
                self.shopListTableView.isHidden = true
                self.showAlert(message: response["Message"] as! String, Title: "Alert")
            }
        }, completionError:  { (error) in
            self.stopAnimating()
            let errorResponse = error as NSDictionary
            if errorResponse.value(forKey: "errorType") as! NSNumber == 1 {
                self.shopListTableView.isHidden = true
                self.present(AppUtility.showInternetErrorMessage(title: "", errorMessage: kNoInterNetMessage, completion: {
                    self.shopListApiCall(routeId: routeId)
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
            print(routeListArray)
            let routeId = routeListArray[ind]["rout_id"] as! String
            shopListApiCall(routeId : routeId )
        } else {
            self.shopListTableView.isHidden = true
        }
    }
    
    
    @IBAction func logOutBtnAction(_ sender: Any) {
            startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
            let url = "http://globemobility.in/admin/Mobile/OUT_from_shop"
        let Parameter = ["shopid": "1","latitude":latitudeValue,"longitude":longitudeValue]
            NetworkHelper.shareWithPars(parameter: Parameter ,method: .post, url: url, completion: { (result) in
                self.stopAnimating()
                let response = result as NSDictionary
                let resultValue = response["Result"] as! String
                if resultValue == "True" {
                    let loginVc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
                    self.navigationController?.pushViewController(loginVc!, animated: true)

                } else {
                    self.showAlert(message: response["Message"] as! String, Title: "Alert")
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
}
extension ShopListViewController : UITableViewDataSource,UITableViewDelegate,shopInBtnTableViewCellDelegate {
    func shopIn(selectedIndexPath: IndexPath,buttonName: String) {
        if buttonName == "in" {
//            if  shopListArray[selectedIndexPath.row].lat == latitudeValue &&  shopListArray[selectedIndexPath.row].long == longitudeValue {
                let mobListVc = storyboard?.instantiateViewController(withIdentifier: "MobileBrandListViewController") as? MobileBrandListViewController
                mobListVc!.shopId = shopListArray[selectedIndexPath.row].shopID
                mobListVc!.lat = shopListArray[selectedIndexPath.row].lat
                mobListVc!.long = shopListArray[selectedIndexPath.row].long
                self.navigationController?.pushViewController(mobListVc!, animated: true)
        } else if buttonName == "report" {
            let repListVc = storyboard?.instantiateViewController(withIdentifier: "ReportListViewController") as? ReportListViewController
            repListVc!.shopid = shopListArray[selectedIndexPath.row].shopID
            self.navigationController?.pushViewController(repListVc!, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopListTableViewCell = shopListTableView.dequeueReusableCell(withIdentifier: "ShopListTableViewCell", for: indexPath) as! ShopListTableViewCell
         let shopdict = shopListArray[indexPath.row]
        cell.setCell(viewModel : shopdict , indexPath : indexPath)
        cell.delegateObject = self
        return cell
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
