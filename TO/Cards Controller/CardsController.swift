//
//  CardsController.swift
//  TO
//
//  Created by RX Group on 20.02.2021.
//

import UIKit

class CardsController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var emptylbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formaterDateFilter = DateFormatter()
            formaterDateFilter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if(arrayCards.count > 0){
            arrayCards = arrayCards.filter({formaterDateFilter.date(from: $0.regCard.dateTime)! > Date()})
        }
        table.tableFooterView = UIView()
        table.isHidden = arrayCards.count < 1
        emptylbl.isHidden = arrayCards.count > 0
        table.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func call(button:UIButton){
        var phone = arrayCards[button.tag].phone!
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
    
    @objc func deleteCard(button:UIButton){
        let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите отменить запись?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .destructive, handler: { action in
            deleteRequest(URLString: mainDomen + "/api/v1/Maintenances/\(arrayCards[button.tag].id!)", completion: {
                DispatchQueue.main.async {
                    arrayCards.remove(at: button.tag)
                    self.table.reloadData()
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(arrayCards), forKey:"cards")
                    self.table.isHidden = arrayCards.count < 1
                    self.emptylbl.isHidden = arrayCards.count > 0
                }
                
            })
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }

}


extension CardsController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return arrayCards[indexPath.row].adress.height(withConstrainedWidth: self.table.frame.size.width-64, font: UIFont(name: "SF UI Display Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)) + 110 + (arrayCards[indexPath.row].phone != nil && arrayCards[indexPath.row].phone != "" ? 20:0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CardCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CardCell
        let formatterHours = DateFormatter()
            formatterHours.dateFormat = "HH:mm"
        let formatterDays = DateFormatter()
            formatterDays.dateFormat = "dd.MM"
        let formaterDate = DateFormatter()
            formaterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        cell.adressLbl.text = arrayCards[indexPath.row].adress
        cell.dateLbl.text = formatterDays.string(from: formaterDate.date(from: arrayCards[indexPath.row].regCard.dateTime)!)
        cell.timeLbl.text = formatterHours.string(from: formaterDate.date(from: arrayCards[indexPath.row].regCard.dateTime)!)
        cell.callbtn.isHidden = !(arrayCards[indexPath.row].phone != nil && arrayCards[indexPath.row].phone != "")
        cell.callbtn.tag = indexPath.row
        cell.callbtn.addTarget(self, action: #selector(call), for: .touchUpInside)
        cell.deleteBtn.isHidden = arrayCards[indexPath.row].id == nil
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(deleteCard), for: .touchUpInside)
        return cell
    }
    
    
}
