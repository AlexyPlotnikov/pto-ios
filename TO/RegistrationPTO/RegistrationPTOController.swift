//
//  RegistrationPTOController.swift
//  TO
//
//  Created by RX Group on 19.02.2021.
//

import UIKit
import CoreLocation

extension Notification.Name {
    public static let updatePTO = Notification.Name(rawValue: "updatePTO")
    public static let closeAll = Notification.Name(rawValue: "closeAll")
    public static let goPTO = Notification.Name(rawValue: "goPTO")
}

class RegistrationPTOController: UIViewController {

    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noTimeLbl: UILabel!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var adressView: UIView!
    @IBOutlet weak var distanceLbl: UILabel!
    
    @IBOutlet weak var adressViewHeight: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var viewWithPicker: UIView!
    @IBOutlet weak var resetBtn: UIButton!
    
    var timeArray:[TimeModel] = []
    var timeChecked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adressViewHeight.constant = currentPTO.address.height(withConstrainedWidth: adressView.frame.size.width-116, font: UIFont(name: "SF UI Display Medium", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)) + 64
        self.view.layoutSubviews()
        if(LocationManager.shared.lastLocation != nil && currentPTO.isRecommended){
            let coordinate1 = CLLocation(latitude: currentPTO.latitude, longitude: currentPTO.longitude)
            let coordinate2 = LocationManager.shared.lastLocation!
           
            let distanceInMeters = coordinate1.distance(from: coordinate2)
            print(coordinate1)
            var distance = ""
            if(distanceInMeters <= 1000){
                distance = String(format: "%.01f м", distanceInMeters)
            }else{
                distance = String(format: "%.01f км", distanceInMeters/1000)
            }
          
            distanceLbl.text = distance
        }else{
            distanceLbl.text = ""
        }
        
        
        
        callBtn.isHidden = currentPTO.phone == nil
        
        self.table.tableFooterView = UIView()
        self.addressLbl.text = currentPTO.address
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePTO), name: .updatePTO, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(registrationCard.dateTime != ""){
            self.loadTimeByDate()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adressView.backgroundColor = .white
        adressView.layer.shadowColor = UIColor.black.cgColor
        adressView.layer.shadowOffset = CGSize(width: 0, height: 0)
        adressView.layer.shadowRadius = 15.0
        adressView.layer.shadowOpacity = 0.13
        adressView.layer.masksToBounds = false
        adressView.layer.shadowPath = UIBezierPath(roundedRect: adressView.bounds, cornerRadius: 5).cgPath
        adressView.layer.cornerRadius = 5
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        let cellSize = CGSize(width:collectionView.frame.size.width/4 - 12 , height:60)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        layout.minimumLineSpacing = 8.0
        layout.minimumInteritemSpacing = 4.0
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.allowsMultipleSelection = false
    }
    
    @objc func updatePTO(){
        self.table.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    
    func showDatePicker() {
            datePicker.minimumDate = Date()
            datePicker.locale = .current
            datePickerView.isHidden = false
        }
    
    @IBAction func reset(_ sender: Any) {
       
        self.resetBtn.isHidden = true
        self.datePicker.date = Date()
        registrationCard.dateTime = ""
        self.table.reloadData()
    }

    
    @IBAction func dateSet() {
            let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                registrationCard.dateTime = formatter.string(from: datePicker.date)
            self.loadTimeByDate()
            self.table.reloadData()
        }
    
    @IBAction func cancelDate(_ sender: Any) {
        datePickerView.isHidden = true
    }
    
    func loadTimeByDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let formaterDate = DateFormatter()
            formaterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        datePickerView.isHidden = true
        
        getRequest(URLString: mainDomen + "/api/v1/Tips/\(currentPTO.id)/maintenances/dates/\(dateFormatter.string(from: formaterDate.date(from: registrationCard.dateTime)!))/free", completion: {
            result in
            DispatchQueue.main.async {
                do {
                    //сериализация справочника в Data, чтобы декодировать ее в структуру
                   let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                   self.timeArray = try! JSONDecoder().decode([TimeModel].self, from: jsonData)
                    self.timeChecked=false
                    if(self.timeArray.count>0){
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        self.timeArray = self.timeArray.sorted { dateFormatter.date(from: $0.dateTime)! < dateFormatter.date(from: $1.dateTime)! }
                        self.timeArray = self.timeArray.filter({dateFormatter.date(from: $0.dateTime)! > Date()})
                    }
                    self.noTimeLbl.isHidden = self.timeArray.count > 0
                   
                    for i in 0..<self.timeArray.count{
                        if let cell = self.collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? TimeCollectionCell{
                            cell.isSelected = false
                            cell.toggleSelected()
                        }
                        
                    }
                    self.collectionView.reloadData()

                    
                  
                }catch{

                }
            }
        })

    }
    
    @IBAction func call(_ sender: Any) {
        var phone = currentPTO.phone!
        if phone.prefix(1) == "8"{
            let prefix = "8" // What ever you want may be an array and step thru it
            if (phone.hasPrefix(prefix)){
                phone  = String(phone.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines))
                phone = "+7"+phone
            }
        }
        let vowels: Set<Character> = [" ", "(", ")", "-"]
        phone.removeAll(where: { vowels.contains($0) })
        if let url = URL(string: "tel://\(phone)") {
            UIApplication.shared.openURL(url)
        }
    }
    
    func checkDay(date:Date)->String{
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "(Сегодня)" }
        else if calendar.isDateInTomorrow(date) { return "(Завтра)" }else{
            return ""
        }
    }
    
//    func checkReady()->Bool{
//        return registrationCard.dateTime != "" && registrationCard.vehicleMark != "" && timeChecked
//    }
    
    @IBAction func goNext(_ sender: Any) {
        if(registrationCard.vehicleMark == ""){
            setMessage(text: "Необходимо указать марку транспортного средства", controller: self)
        }else if(registrationCard.dateTime == ""){
            setMessage(text: "Необходимо указать дату для записи на ТО", controller: self)
        }else if(!timeChecked){
            setMessage(text: "Необходимо указать время записи на ТО", controller: self)
        }else{
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "readyVC") as! ReadyPTOController
                       self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    @IBAction func openMap(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "mapVC") as! MapController
        self.present(viewController, animated: true, completion: nil)
        
    }
    
    
}


extension RegistrationPTOController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RegistrationPTOCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RegistrationPTOCell
        if(indexPath.row == 0){
            cell.titleLbl.text = registrationCard.vehicleMark.count > 0 ? registrationCard.vehicleMark + " " + registrationCard.vehicleModel:"Ваше транспортное средство"
            cell.imageIcon.image = UIImage(named: "carIcon")
        }else{
            cell.imageIcon.image = UIImage(named: "calendarIcon")
            let formatter = DateFormatter()
                formatter.dateFormat = "dd MMMM YYYY"
            let formaterDate = DateFormatter()
                formaterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            cell.titleLbl.text = registrationCard.dateTime.count > 0 ? formatter.string(from: formaterDate.date(from: registrationCard.dateTime)!):"Выберите дату записи"
           
            if(registrationCard.dateTime != ""){
                cell.titleLbl.text = cell.titleLbl.text! + " \(self.checkDay(date: formaterDate.date(from: registrationCard.dateTime)!))"
            }
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "chooseCarVC") as! ChooseCarController
            self.present(viewController, animated: true, completion: nil)
        }else{
                self.showDatePicker()
            
        }
    }
    
    
}

extension RegistrationPTOController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.timeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:TimeCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TimeCollectionCell
        
            
        let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
        let formaterDate = DateFormatter()
            formaterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            cell.timeLbl.text = formatter.string(from: formaterDate.date(from: timeArray[indexPath.row].dateTime)!)
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = UIColor.init(displayP3Red: 225/255, green: 225/255, blue: 225/255, alpha: 1).cgColor
        cell.contentView.layer.cornerRadius = 5
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            registrationCard.dateTime = self.timeArray[indexPath.row].dateTime
            let cell = collectionView.cellForItem(at: indexPath) as! TimeCollectionCell
            cell.toggleSelected()
            self.timeChecked=true
        }
           
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async {
        let cell = collectionView.cellForItem(at: indexPath) as! TimeCollectionCell
        cell.toggleSelected()
        }
    }
    
}


extension UICollectionView {

    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
}
