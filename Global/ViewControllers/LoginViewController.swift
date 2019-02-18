//
//  ViewController.swift
//  Global
//
//  Created by akshay Avati on 11/02/19.
//  Copyright © 2019 akshay Avati. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import GBFloatingTextField
import NVActivityIndicatorView

class LoginViewController: UIViewController,CLLocationManagerDelegate,NVActivityIndicatorViewable {
    
    @IBOutlet weak var passwordTxtField: GBTextField!
    @IBOutlet weak var usernameTextField: GBTextField!
    var longitudeValue = ""
    var latitudeValue = ""
    var currentLocation: CLLocation! = nil
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTxtField.delegate = self
        usernameTextField.delegate = self
        passwordTxtField.lineColor = .black
        passwordTxtField.titleLabelColor = .black
        passwordTxtField.lineHeight = 1
        self.view.addSubview(passwordTxtField)
        usernameTextField.lineColor = .black
        usernameTextField.titleLabelColor = .black
        usernameTextField.lineHeight = 1
        self.view.addSubview(usernameTextField)

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

    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            longitudeValue = "\(location.coordinate.longitude)"
            latitudeValue  = "\(location.coordinate.latitude)"
        }
    }
    
    // If we have been deined access give the user the option to change it
    
    @available(iOS 4.2, *)
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        locationManager.startUpdatingLocation()

    }
    @IBAction func loginBtnClicked(_ sender: Any) {
        
        let shopListVc = self.storyboard?.instantiateViewController(withIdentifier: "MobileBrandListViewController") as? MobileBrandListViewController
        self.navigationController?.pushViewController(shopListVc!, animated: true)
    //login()
    }
    func login() {
        startAnimating(kActivityIndicatorSize, message: kLoadingMessageForHud, type: NVActivityIndicatorType(rawValue: kActivityIndicatorNumber)! )
        let url = "http://globemobility.in/admin/Mobile/checklogin?userid=\(String(describing: usernameTextField.text!))&password=\(String(describing: passwordTxtField.text!))&latitude=\(longitudeValue)&longitude=\(latitudeValue)"
        NetworkHelper.shareWithPars(parameter: nil,method: .get, url: url, completion: { (result) in
            self.stopAnimating()
            let response = result as NSDictionary
            print(response)
        }, completionError:  { (error) in
            self.stopAnimating()
            let errorResponse = error as NSDictionary
            if errorResponse.value(forKey: "errorType") as! NSNumber == 1 {
                self.dismiss(animated: false, completion: {
                    self.showAlert(message: kNoInterNetMessage, Title: KLoginFailed )
                })
            }  else if errorResponse.value(forKey: "errorType") as! NSNumber == 2 {
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

}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return false
    }
}
