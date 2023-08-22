//
//  RXServerConnector.swift
//  AdminAbie
//
//  Created by Алексей on 05.11.2019.
//  Copyright © 2019 Алексей. All rights reserved.
//

import Foundation
import UIKit

var taskArray:NSMutableArray = []
var mainDomen = "https://master-pto.rx-agent.ru"

class RXServerConnector: NSObject,URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    static let sharedInstance = RXServerConnector()
   
   
    
}

//func refreshToken(controller:UIViewController,completion:@escaping ()->Void){
//    do {
//        let jwt = try decode(jwt: mainUser.token)
//        let expDate = Date(timeIntervalSince1970: (TimeInterval(jwt.body["exp"] as! Int)))
//        let currentDate = Date()
//
//        if(expDate <= currentDate){
//                let model = ["refreshToken":mainUser.refreshToken] as [String:Any]
//                postRequest(JSON: model, URLString:mainDomen+"/api/account/tokens/refresh", completion: {
//                    result in
//                    DispatchQueue.main.async {
//                    if(result["errors"] == nil){
//                        do {
//                            //сериализация справочника в Data, чтобы декодировать ее в структуру
//                            let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
//                            let review = try! JSONDecoder().decode(Person.self, from: jsonData)
//                            let encoder = JSONEncoder()
//                            if let encoded = try? encoder.encode(review) {
//                               let defaults = UserDefaults.standard
//                               defaults.set(encoded, forKey: "SavedPerson")
//                            }
//                           do{
//                               let jwt = try decode(jwt: review.accessToken!)
//                               let fullName = jwt.body["fullname"] as! String
//                               let organization = jwt.body["contractortitle"] as! String
//                               let login = jwt.body["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"] as! String
//                                   mainUser = User(name: fullName, login: login, organizaton: organization, token: review.accessToken!, refreshToken: review.refreshToken!)
//                                   completion()
//                           }catch{
//
//                           }
//                        } catch {
//                            print(error.localizedDescription)
//                        }
//                    }else{
//                        if((result["errors"] as! [String:Any])["errors"] != nil){
//                            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "startVC") as! SwipeNavigationController
//                                viewController.modalPresentationStyle = .fullScreen
//                                controller.present(viewController, animated: true, completion: nil)
//                        }
//                    }
//                    }
//                })
//        }else{
//            completion()
//        }
//
//
//    } catch  {
//
//    }
//}

func deleteRequest(URLString:String, completion:@escaping ()->Void) {
    print(URLString)
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
        request.httpMethod = "DELETE"
        request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")

    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
           do {
            if let response = response as? HTTPURLResponse, 200 == response.statusCode {
                            completion()
                        }
           }
    })
    
    task.resume()
}


func getRequest(URLString:String, completion:@escaping (_ array: NSArray)->Void) {
    print(URLString)
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
        request.httpMethod = "GET"
        request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")

    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
         guard let data = data else { return }
           do {
            if let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSArray{
                completion(GETdata)
            }else{
                completion([])
            }
           
             
           } catch  {
            print(error.localizedDescription)
           completion([])
       }
    })
    
    task.resume()
}

func getDictionaryRequest(URLString:String, completion:@escaping (_ array: [String:Any])->Void) {
    
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
        request.httpMethod = "GET"
    request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
         guard let data = data else { return }
           do {

            if let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                 completion(GETdata)
            }else{
                let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
                print(GETdata)
            }
           
            
       } catch let error as NSError {
           print(error)
       }
    })
    
    task.resume()
}
func getStringRequest(URLString:String, completion:@escaping (_ array:String)->Void) {
    
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
        request.httpMethod = "GET"
    request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
         guard let data = data else { return }
           do {
            let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
           
             completion(GETdata)
       } catch let error as NSError {
           print(error)
       }
    })
    
    task.resume()
}
func getRatingRequest(URLString:String, completion:@escaping (_ number:NSNumber)->Void) {
    
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
        request.httpMethod = "GET"
    request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
         guard let data = data else { return }
           do {
            let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSNumber
           
             completion(GETdata)
       } catch let error as NSError {
           print(error)
       }
    })
    
    task.resume()
}

func postRequest(JSON:[String: Any], URLString:String, completion:@escaping (Dictionary<String, Any>)->Void) {
    
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
    
    request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
    request.httpMethod = "POST"
  
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
    } catch let error {
        print(error.localizedDescription)
    }
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
   
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
        
        guard let data = data else {
            
            return
        }
        do {
            if let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                 completion(GETdata)
            }else{
                let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
                completion(["id":GETdata])
                
            }
        } catch {
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode == 200){

                    completion([:])
                }
            }
        }
        
    })
    
    task.resume()
}
func postRequestNoJSON(URLString:String, completion:@escaping (Dictionary<String, Any>)->Void) {
    
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
    request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
        request.httpMethod = "POST"
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
        
        guard let data = data else { return }
        do {
             
            completion(try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any])
        } catch let error as NSError {
            
            print(error)
        }
    })
    
    task.resume()
}

func patchRequest(JSON:[String: Any], URLString:String, completion:@escaping (Dictionary<String, Any>)->Void) {
    
    var request = URLRequest(url: NSURL(string: URLString)! as URL)
    
    request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
        request.httpMethod = "PATCH"
  
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: JSON, options: .prettyPrinted)
    } catch let error {
        print(error.localizedDescription)
    }
    
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
   
    let task = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
        
        guard let data = data else {
            
            return
        }
        do {
            if let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                 completion(GETdata)
            }else{
                let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
                completion(["id":GETdata])
                
            }
        } catch {
            if let httpResponse = response as? HTTPURLResponse {
                if(httpResponse.statusCode == 200){

                    completion([:])
                }
            }
        }
        
    })
    
    task.resume()
}
func uploadImage(URLString:String, image:UIImage,param: [String:String], completion:@escaping (Dictionary<String, Any>)->Void) {
       let myUrl = NSURL(string: URLString)
       var request = URLRequest(url:myUrl! as URL)
    request.addValue("1cdb8148-69ac-47a3-85f3-5440e85cbd5f", forHTTPHeaderField: "x-api-key")
       request.httpMethod = "POST"
       let boundary = generateBoundaryString()
       request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
       let imageData = image.jpegData(compressionQuality: 0.1)
       
       if(imageData==nil)  { return }
       
       request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "AttachedFiles", imageDataKey: imageData! as NSData, boundary: boundary) as Data
       let opQueue = OperationQueue()
       opQueue.isSuspended = true
       let sessionConfiguration = URLSessionConfiguration.default
       sessionConfiguration.urlCache = nil
       
       let task = URLSession.shared.dataTask(with: request, completionHandler:  {(data, response, error) in
           guard let data = data else { return }
           do {
            
           
            if let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                 completion(GETdata)
            }else{
                let GETdata  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Bool
                completion(["completed":GETdata])
                
            }
             
           } catch let error as NSError {
               print(error.localizedDescription)
           }
       })
      task.resume()
       
   }


//func uploadImageArray(URLString:String, image:UIImage, name: NSString, completion:@escaping (NSArray)->Void) {
//    let myUrl = NSURL(string: URLString)
//    var request = URLRequest(url:myUrl! as URL)
//    if !mainUser.token.isEmpty {
//         
//             request.addValue("Bearer \(mainUser.token)", forHTTPHeaderField: "Authorization")
//         
//    }
//    request.httpMethod = "POST"
//    let boundary = generateBoundaryString()
//    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//    let imageData = image.jpegData(compressionQuality: 0.1)
//    
//    if(imageData==nil)  { return }
//    
//    request.httpBody = createBodyWithParameters( filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary, filename: name as String) as Data
//    let opQueue = OperationQueue()
//    opQueue.isSuspended = true
//    let sessionConfiguration = URLSessionConfiguration.default
//    sessionConfiguration.urlCache = nil
//    
//    let task = URLSession.shared.dataTask(with: request, completionHandler:  {(data, response, error) in
//        guard let data = data else { return }
//        do {
//         
//        
//             let movieData  =  try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSArray
//                   completion(movieData)
//          
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//    })
//   task.resume()
//    
//}

func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();

        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }

        let filename = "user-profile.jpg"

        let mimetype = "image/jpg"

    body.appendString(string: "--\(boundary)\r\n")
    body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
    body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
    body.append(imageDataKey as Data)
    body.appendString(string: "\r\n")

    body.appendString(string: "--\(boundary)--\r\n")

        return body
    }



func generateBoundaryString() -> String {
    return "Boundary-\(NSUUID().uuidString)"
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
