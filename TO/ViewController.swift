//
//  ViewController.swift
//  TO
//
//  Created by RX Group on 15.02.2021.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController,MKMapViewDelegate {
    

   // var locationManager = CLLocationManager()
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var mainView: ViewWithShadows!
    @IBOutlet weak var countryField: UITextField!
    @IBOutlet weak var geolocationConst: NSLayoutConstraint!
    @IBOutlet weak var chooseCountryLbl: UILabel!
    @IBOutlet weak var table: UITableView!
    var oldY:CGFloat = 0.0
    @IBOutlet weak var searchView: ViewWithShadows!
    @IBOutlet weak var heightSearchView: NSLayoutConstraint!
    @IBOutlet weak var arrow: UIImageView!
    
    
    @IBOutlet var mapView: MKMapView!
    
    
    var cityIndex = 0
    var nameCity = ""
    
    var cityArray:[City] = []
    var searchCityArray: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 5)
        
        if let data = UserDefaults.standard.value(forKey:"cities") as? Data {
            DispatchQueue.main.async {
                self.cityArray = try! PropertyListDecoder().decode(Array<City>.self, from: data)
                self.searchCityArray = self.cityArray.filter({(($0.name).localizedCaseInsensitiveContains(self.nameCity))})
                LocationManager.shared.delegate = self
                self.checkLocation()
            }
        }else{
            getRequest(URLString:mainDomen + "/api/v1/Cities", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.cityArray = try! JSONDecoder().decode([City].self, from: jsonData)
                        self.searchCityArray = self.cityArray.filter({(($0.name).localizedCaseInsensitiveContains(self.nameCity))})
                        LocationManager.shared.delegate = self
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.cityArray), forKey:"cities")
                        self.checkLocation()
                    }catch{

                    }
                }
            })
        }
        countryField.delegate = self
        countryField.attributedPlaceholder = NSAttributedString(string: "Укажите город",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(displayP3Red: 162/255, green: 162/255, blue: 162/255, alpha: 1)])
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
            request.requestsAlternateRoutes = false
            request.transportType = .automobile

            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                if let response = response {
                                self.showRoute(response)
                            }
                if let route = response?.routes.first {
                    
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
                }
            }
        }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
             renderer.strokeColor = UIColor.red
             renderer.lineWidth = 4.0
             return renderer
        }
    
    func showRoute(_ response: MKDirections.Response) {
        
        for route in response.routes {
            
            self.mapView.addOverlay(route.polyline,
                         level: MKOverlayLevel.aboveRoads)
            
            for step in route.steps {
                print(step.instructions)
            }
        }
        
        if let coordinate = LocationManager.shared.lastLocation?.coordinate {
            let region =
                MKCoordinateRegion(center: coordinate,
                                   latitudinalMeters: 100, longitudinalMeters: 100)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nextBtn.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 5)
    }
    
    @objc func handleTap(){
        self.heightSearchView.constant = 0
        self.searchView.isHidden = true
        self.view.endEditing(true)
    }
    
    func checkLocation(){
        
        if(LocationManager.shared.lastLocation == nil){
            self.geolocationConst.constant = 0
            print("1")
        }else{
           
            CLGeocoder().reverseGeocodeLocation(LocationManager.shared.lastLocation!, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    return
                }else if let city = placemarks?.first?.locality{
                     self.nameCity = "\(city)"
                     self.searchCityArray = self.cityArray.filter({$0.name.lowercased().prefix(self.nameCity.count) == self.nameCity.lowercased()})
                     print(self.searchCityArray)
                     self.countryField.text = self.nameCity
                     self.geolocationConst.constant = 15
                 } else {
                     self.geolocationConst.constant = 0
                }
            })
        }
                   
                
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    func showAlertMessage(messageTitle: String, withMessage: String) {
        let alertController = UIAlertController(title: messageTitle as String, message: withMessage as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (action:UIAlertAction!) in

        }
        alertController.addAction(cancelAction)

        let OKAction = UIAlertAction(title: "Настройки", style: .default) { (action:UIAlertAction!) in
            if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION/RXGroup.TO") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }

    @IBAction func nextStep(_ sender: Any) {
        if(self.nameCity != ""){
            print("123")
            if(self.searchCityArray.count > 0){
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "categoryVC") as! ChooseCategoryController
                currentCity = self.searchCityArray[cityIndex]
                self.navigationController?.pushViewController(viewController, animated: true)
            }else{
                setMessage(text: "К сожалению вашего города еще нет в списке, но мы над этим работаем", controller: self)
            }
        }else{
            setMessage(text: "Вы не указали населенный пункт", controller: self)
        }
    }
    
    @IBAction func goCard(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "cardsVC") as! CardsController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    
}

extension ViewController:LocationManagerDelegate{
    func getLocationUpdate() {
        
    }
    
    
    func locationUpdeted() {
        self.checkLocation()
    }
   
}


extension ViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.geolocationConst.constant = 0
        self.logo.isHidden = true
        self.chooseCountryLbl.isHidden = true
        self.nextBtn.isHidden = true
        self.arrow.isHidden = true
        textField.text = ""
        self.mainView.translatesAutoresizingMaskIntoConstraints = true
        self.oldY = self.mainView.frame.origin.y
        self.mainView.frame.origin.y = self.logo.frame.origin.y
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.geolocationConst.constant = 15
        self.logo.isHidden = false
        self.chooseCountryLbl.isHidden = false
        self.nextBtn.isHidden = false
        self.arrow.isHidden = false
        self.countryField.text = self.nameCity
        self.mainView.translatesAutoresizingMaskIntoConstraints = false
        self.mainView.frame.origin.y = self.oldY
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range:
     NSRange, replacementString string: String) -> Bool{

       let searchText  = textField.text! + string
        
        self.searchCityArray = self.cityArray.filter({$0.name.lowercased().prefix(searchText.count) == searchText.lowercased()})
            self.nameCity = searchText
        DispatchQueue.main.async {
            self.heightSearchView.constant = CGFloat(self.searchCityArray.count > 0 ? self.searchCityArray.count * 54:0)
            self.searchView.isHidden = self.searchCityArray.count < 1
            self.table.reloadData()
        }
        
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.heightSearchView.constant = 0
        self.searchView.isHidden = true
        self.arrow.isHidden = false
        return true
    }
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchCityArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            if(cell == nil){
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.init(displayP3Red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
            cell?.textLabel?.text = self.searchCityArray[indexPath.row].name
            cell?.textLabel?.textColor = UIColor.init(displayP3Red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
       
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.nameCity = self.searchCityArray[indexPath.row].name
        cityIndex = indexPath.row
        self.countryField.text = self.nameCity
        self.heightSearchView.constant = 0
        self.searchView.isHidden = true
    }
}



extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

func setMessage(text:String, controller:UIViewController) {
    DispatchQueue.main.async{
        let alertController = UIAlertController(title: "Внимание!", message:
            text , preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
}
