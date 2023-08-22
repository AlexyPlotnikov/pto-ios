//
//  ChooseCarController.swift
//  TO
//
//  Created by RX Group on 20.02.2021.
//

import UIKit

class ChooseCarController: UIViewController {

    @IBOutlet weak var table: UITableView!
    var vehicleArray:[Vehicle] = []
    var searchArray:[Vehicle] = []
    var isSearch = false
    var isModel = false
    var choosenIndex = 0
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.tableFooterView = UIView()
        searchBar.delegate = self
        getRequest(URLString: mainDomen + "/api/v1/Vehicles", completion: {
            result in
            DispatchQueue.main.async {
                do {
                    //сериализация справочника в Data, чтобы декодировать ее в структуру
                   let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                   self.vehicleArray = try! JSONDecoder().decode([Vehicle].self, from: jsonData)
                   
                   self.table.reloadData()
                }catch{

                }
            }
        })
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    @IBAction func back(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ChooseCarController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!isModel){
            return isSearch ? self.searchArray.count + 1:self.vehicleArray.count + 1
        }else{
            if(isSearch ? (self.searchArray.count > 0):(self.vehicleArray.count > 0)){
                return isSearch ? self.searchArray[choosenIndex].cars!.count + 1:self.vehicleArray[choosenIndex].cars!.count + 1
            }else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            if(cell == nil){
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell?.selectionStyle = .none
            
        if(!isModel){
            if(indexPath.row == 0){
                cell?.textLabel?.text = "Другая марка"
                cell?.accessoryType = .none
            }else{
            cell?.textLabel?.text = isSearch ? searchArray[indexPath.row-1].title:vehicleArray[indexPath.row-1].title
            cell?.accessoryType = .disclosureIndicator
            }
        }else{
            if(indexPath.row == 0){
                cell?.textLabel?.text = "Другая модель"
                cell?.accessoryType = .none
            }else{
                cell?.textLabel?.text = isSearch ? searchArray[choosenIndex].cars![indexPath.row-1].model:vehicleArray[choosenIndex].cars![indexPath.row-1].model
                cell?.accessoryType = .none
            }
        }
            cell?.backgroundColor = .white
            cell?.textLabel?.textColor = .black

        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!isModel){
            if(indexPath.row==0){
                registrationCard.vehicleMark = "Другая марка"
                registrationCard.vehicleModel = ""
                NotificationCenter.default.post(name: .updatePTO, object: nil, userInfo: nil)
                self.dismiss(animated: true, completion: nil)
            }else{
                registrationCard.vehicleMark = isSearch ? searchArray[indexPath.row-1].title:vehicleArray[indexPath.row-1].title
              
                if(isSearch ? (searchArray[indexPath.row-1].cars!.count > 0): (vehicleArray[indexPath.row-1].cars!.count > 0)){
                    isModel = true
                    choosenIndex = indexPath.row - 1
                    table.reloadData()
                    searchBarHeight.constant = 0
                    searchBar.resignFirstResponder()
                }else{
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            if(indexPath.row==0){
                registrationCard.vehicleModel = "Другая модель"
            }else{
                registrationCard.vehicleModel = isSearch ? searchArray[choosenIndex].cars![indexPath.row-1].model:vehicleArray[choosenIndex].cars![indexPath.row-1].model
            }
            
            
            NotificationCenter.default.post(name: .updatePTO, object: nil, userInfo: nil)
            self.dismiss(animated: true, completion: nil)

        }
    }
    
    
}

extension ChooseCarController:UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.isSearch = searchText.count > 0
        self.searchArray = self.vehicleArray.filter({(($0.title).localizedCaseInsensitiveContains(searchText))})
        self.table.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.isSearch = false
        self.table.reloadData()
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

