//
//  PTOController.swift
//  TO
//
//  Created by RX Group on 18.02.2021.
//

import UIKit
import CoreLocation

class PTOController: UIViewController {
  
    
    @IBOutlet weak var cityBtn: UIButton!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var emptyLbl: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var viewWithPicker: UIView!
    @IBOutlet weak var resetBtn: UIButton!
    
    
    var isFiltered = false

    var arrayPTO:[PTO] = []
    var recommendArray: [PTO] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPTO(parameterDate: "",needReload:true,completion: {})
        self.table.tableFooterView = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func loadPTO(parameterDate:String,needReload:Bool,completion:@escaping ()->Void){
        getRequest(URLString: mainDomen + "/api/v1/Cities/names/\(currentCity.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/tips?category=\(registrationCard.vehicleCategoryID)" + parameterDate, completion: {
            result in
            
            DispatchQueue.main.async {
                if(result.count > 0){
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                        let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        self.serialozation(data: jsonData, needReload: needReload)
                        completion()
                    }catch{

                    }
                }else{
                    let currentCategory = CategoryEnum(rawValue: registrationCard.vehicleCategoryID)
                    getRequest(URLString: mainDomen + "/api/v1/Cities/names/\(currentCity.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)/tips?category=\(currentCategory!.name)" + parameterDate, completion: {
                        result in
                        DispatchQueue.main.async {
                                do {
                                    //сериализация справочника в Data, чтобы декодировать ее в структуру
                                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                                    self.serialozation(data: jsonData, needReload: needReload)
                                    completion()
                                }catch{

                                }
                        }
                    })
                }
            }
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        UIView.animate(withDuration: 0.2, animations: {
            self.viewWithPicker.frame.origin.y -= 100
        })
        
        
       }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self.viewWithPicker.frame.origin.y += 100
    }
    
    func serialozation(data:Data,needReload:Bool){
        self.arrayPTO = try! JSONDecoder().decode([PTO].self, from: data)
         if(LocationManager.shared.lastLocation != nil){
             self.arrayPTO = self.sortPTO(filials: self.arrayPTO, by: LocationManager.shared.lastLocation!)
        
         }
        self.recommendArray = self.arrayPTO.filter({($0.isRecommended) == true})
        self.arrayPTO = self.arrayPTO.filter({($0.isRecommended) == false})
        if(needReload){
            self.table.reloadData()
        }
    }
    
    func sortPTO(filials: [PTO], by location: CLLocation) -> [PTO] {
        
        return filials.sorted { (filial1, filial2) -> Bool in
            let location1 = CLLocation(latitude: filial1.latitude, longitude: filial1.longitude)
            let location2 = CLLocation(latitude: filial2.latitude, longitude: filial2.longitude)
            
            let distance1 = location.distance(from: location1)
            let distance2 = location.distance(from: location2)
            
            return distance1 < distance2
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    func showDatePicker() {
            datePicker.minimumDate = Date()
            datePicker.locale = .current
            datePickerView.isHidden = false
        }
    
    @IBAction func reset(_ sender: Any) {
        self.loadPTO(parameterDate: "",needReload:true,completion: {
            self.cityBtn.setImage(UIImage(named: "filterIcon"), for: .normal)
            self.resetBtn.isHidden = true
            self.isFiltered=false
            self.datePicker.date = Date()
        })
       
    }
    
    
    
    @IBAction func dateSet() {
                cityBtn.setImage(UIImage(named: "filtericonRed"), for: .normal)
                resetBtn.isHidden = false
                isFiltered=true
                let formaterDate = DateFormatter()
                    formaterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                registrationCard.dateTime = formaterDate.string(from: datePicker.date)
                let formaterparam = DateFormatter()
                formaterparam.dateFormat = "yyyy-MM-dd"
        self.loadPTO(parameterDate:"&date=\(formaterparam.string(from: datePicker.date))", needReload: false,completion: {
            DispatchQueue.main.async {
                let formaterDateFilter = DateFormatter()
                    formaterDateFilter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                self.arrayPTO = self.arrayPTO.filter({formaterDateFilter.date(from: $0.nearestRegister)! >= self.datePicker.date})
                self.recommendArray = self.recommendArray.filter({formaterDateFilter.date(from: $0.nearestRegister)! >= self.datePicker.date})
                self.table.reloadData()
                self.datePickerView.isHidden = true
            }
           
        })
            
        }
    
    
    
    @IBAction func chooseCity(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.showDatePicker()
        })
            
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.datePickerView.isHidden = true
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}




//MARK:Делегат таблицы
extension PTOController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.table.isHidden = self.arrayPTO.count + self.recommendArray.count == 0
        emptyLbl.isHidden = self.arrayPTO.count + self.recommendArray.count > 0
    
        return self.arrayPTO.count + self.recommendArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
            var pto = PTO()
            let formatter = DateFormatter()
                formatter.dateFormat = "dd MMM"
      
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "ru_ru")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
            let formaterDate = DateFormatter()
                formaterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            
            if(indexPath.row < self.recommendArray.count && self.recommendArray.count>0){
                pto = self.recommendArray[indexPath.row]
                let cell:PTOTableViewCell = tableView.dequeueReusableCell(withIdentifier: "recomendPTOcell") as! PTOTableViewCell
                cell.adressRecomend.text = pto.address
                if let dateFromString = dateFormatter.date(from:  pto.nearestRegister) {
                    print(dateFromString)   // "2015-08-19 09:00:00 +0000"
                  //  dateFormatter.timeZone = .current
                    dateFormatter.dateFormat = "hh:mm"
                   
                    cell.dateRec.text = "\(formatter.string(from: formaterDate.date(from: pto.nearestRegister)!)) \(dateFormatter.string(from: dateFromString))"
                }else{
                    cell.dateRec.text = "Нет данных"
                }
                cell.priceRec.text = "от \(pto.price) руб"
                if(LocationManager.shared.lastLocation != nil){
                    let coordinate1 = CLLocation(latitude: pto.latitude, longitude: pto.longitude)
                    let coordinate2 = LocationManager.shared.lastLocation!
                   
                    let distanceInMeters = coordinate1.distance(from: coordinate2)
                    print(coordinate1)
                    var distance = ""
                    if(distanceInMeters <= 1000){
                        distance = String(format: "%.01f м", distanceInMeters)
                    }else{
                        distance = String(format: "%.01f км", distanceInMeters/1000)
                    }
                  
                    cell.distanceRec.text = distance
                }else{
                    cell.distanceRec.text = ""
                }
                return cell
            }else{
                pto = self.arrayPTO[indexPath.row - self.recommendArray.count]
                let cell:PTOTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ptocell") as! PTOTableViewCell
                cell.addressLbl.text = pto.address
                if let dateFromString = dateFormatter.date(from:  pto.nearestRegister) {
                    dateFormatter.dateFormat = "hh:mm"
                    cell.dateLbl.text = "\(formatter.string(from: formaterDate.date(from: pto.nearestRegister)!)) запись доступна с \(dateFormatter.string(from: dateFromString))"
                }else{
                    cell.dateLbl.text = "Нет данных"
                }
                cell.priceLbl.text = "от \(pto.price) руб"
                if(LocationManager.shared.lastLocation != nil){
                    let coordinate1 = CLLocation(latitude: pto.latitude, longitude: pto.longitude)
                    let coordinate2 = LocationManager.shared.lastLocation!
                    let distanceInMeters = coordinate1.distance(from: coordinate2)
                    
                    var distance = ""
                    if(distanceInMeters <= 1000){
                        distance = String(format: "%.01f м", distanceInMeters)
                    }else{
                        distance = String(format: "%.01f км", distanceInMeters/1000)
                    }
                    cell.distanceLbl.text = distance
                }else{
                    cell.distanceLbl.text = ""
                }
                return cell
            }
    
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row < self.recommendArray.count && self.recommendArray.count>0){
            return self.recommendArray[indexPath.row].address.height(withConstrainedWidth: self.table.frame.size.width-80, font: UIFont(name: "SF UI Display Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)) + 80
        }else{
            return self.arrayPTO[indexPath.row-self.recommendArray.count].address.height(withConstrainedWidth: self.table.frame.size.width-110, font: UIFont(name: "SF UI Display Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)) + 60
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row < self.recommendArray.count && self.recommendArray.count>0){
            currentPTO = self.recommendArray[indexPath.row]
            registrationCard.tipId = currentPTO.id
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "registrationVC") as! RegistrationPTOController
            self.navigationController?.pushViewController(viewController, animated: true)
        }else{
            currentPTO = self.arrayPTO[indexPath.row-self.recommendArray.count]
            registrationCard.tipId = currentPTO.id
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "registrationVC") as! RegistrationPTOController
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}



