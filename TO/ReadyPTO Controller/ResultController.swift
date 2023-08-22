//
//  ResultController.swift
//  TO
//
//  Created by RX Group on 20.02.2021.
//

import UIKit

class ResultController: UIViewController {
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var adressLbl: UILabel!
    var idCard:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatterHours = DateFormatter()
            formatterHours.dateFormat = "HH:mm"
        let formatterDays = DateFormatter()
            formatterDays.dateFormat = "dd.MM"
        let formaterDate = DateFormatter()
            formaterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            
        self.adressLbl.text = currentPTO.address
        self.dateLbl.text = formatterDays.string(from: formaterDate.date(from: registrationCard.dateTime)!)
        self.timeLbl.text = formatterHours.string(from: formaterDate.date(from: registrationCard.dateTime)!)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    @IBAction func okaction(_ sender: Any) {
        arrayCards.append(SavedCard(regCard:registrationCard,adress: currentPTO.address,phone: currentPTO.phone ?? "",id: idCard))
        
        let formaterDate = DateFormatter()
            formaterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let formatterHours = DateFormatter()
            formatterHours.dateFormat = "HH:mm"
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Напоминание"
        content.body = "Вы записаны на техосмотр, сегодня в \(formatterHours.string(from: formaterDate.date(from: registrationCard.dateTime)!)) по адресу \(currentPTO.address)"
        content.sound = UNNotificationSound.default

        // Setup trigger time
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var date = DateComponents()
        date.day = formaterDate.date(from: registrationCard.dateTime)!.get(.day)
        date.month = formaterDate.date(from: registrationCard.dateTime)!.get(.month)
        date.year = formaterDate.date(from: registrationCard.dateTime)!.get(.year)
        date.hour = formaterDate.date(from: registrationCard.dateTime)!.get(.hour) - 2
        date.minute = formaterDate.date(from: registrationCard.dateTime)!.get(.minute)
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)

        // Create request
        let uniqueID = UUID().uuidString // Keep a record of this if necessary
        let request = UNNotificationRequest(identifier: uniqueID, content: content, trigger: trigger)
        center.add(request) // Add the notification request
  
        self.dismiss(animated: true, completion: {
            refreshModels()
            NotificationCenter.default.post(name: .closeAll, object: nil, userInfo: nil)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(arrayCards), forKey:"cards")
        })
        
        
    }
    
    
}


extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
