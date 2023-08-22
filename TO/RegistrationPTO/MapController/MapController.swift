//
//  MapController.swift
//  TO
//
//  Created by RX Group on 31.03.2021.
//

import UIKit
import MapKit

class MapController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var adressLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adressLbl.text = currentPTO.address
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: currentPTO.latitude, longitude: currentPTO.longitude))){
            self.setPinUsingMKPointAnnotation(location: CLLocationCoordinate2D(latitude: currentPTO.latitude, longitude: currentPTO.longitude))
        }else{
            setMessage(text: "Мы еще не добавили точку на карте\nВаш ПТО находится по адресу:  \(currentPTO.address)", controller: self)
        }
    }

    func setPinUsingMKPointAnnotation(location: CLLocationCoordinate2D){
       let annotation = MKPointAnnotation()
       annotation.coordinate = location
       annotation.title = currentPTO.address
      // annotation.subtitle = "Device Location"
       let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
       mapView.setRegion(coordinateRegion, animated: true)
       mapView.addAnnotation(annotation)
       
    
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
