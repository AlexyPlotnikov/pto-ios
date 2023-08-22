//
//  Models.swift
//  TO
//
//  Created by RX Group on 19.02.2021.
//

import Foundation


struct City:Codable {
    var id:Int = 0
    var name:String = ""
    var fullname:String = ""
}

var currentCity:City!

struct Category:Codable{
    var id:Int = 0
    var vehicleCategoryID:Int = 0
    var title:String = ""
    var vehicleType:String = ""
    var description:String = ""
}

enum CategoryEnum: Int {
    case A = 1
    case B
    case C
    case D
    case E
    
    var name: String {
            get { return String(describing: self) }
        }
        var description: String {
            get { return String(reflecting: self) }
        }
}

var currentCategory:CategoryEnum!


struct PTO:Codable {
    var id:Int = 0
    var address:String = ""
    var phone:String? = ""
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var nearestRegister:String = ""
    var price:Int = 0
    var isRecommended:Bool = true
}

var currentPTO:PTO!

struct Vehicle:Codable{
    var title:String = ""
    var cars:[ModelVehicle]? = []
}

struct ModelVehicle:Codable{
    var model:String = ""
    var category:String? = ""
    var subCategory:String? = ""
}

struct RegistrationCart:Codable{
      var tipId:Int = 0
      var dateTime:String = ""
      var clientName:String = ""
      var clientPhone:String = ""
      var vehicleMark:String = ""
      var vehicleModel:String = ""
      var vehicleCategoryID: Int = 0
      var sourceRecord:Int? = 3
      var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
          guard let label = label else { return nil }
          return (label, value)
        }).compactMap { $0 })
        return dict
      }
    }

var registrationCard:RegistrationCart! = RegistrationCart()

struct SavedCard:Codable{
    var regCard:RegistrationCart!
    var adress:String!
    var phone:String? = ""
    var id:Int?
}

var arrayCards:[SavedCard] = []

struct TimeModel:Codable{
    var dateTime:String = ""
}


func refreshModels(){
    currentCity = City()
    currentPTO = PTO()
    registrationCard = RegistrationCart()
}

