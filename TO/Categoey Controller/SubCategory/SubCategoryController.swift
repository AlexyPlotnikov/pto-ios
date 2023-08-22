//
//  SubCategoryController.swift
//  TO
//
//  Created by RX Group on 04.03.2021.
//

import UIKit

class SubCategoryController: UIViewController {
    
    @IBOutlet weak var categorylbl: UILabel!
    var subCategoryArray:[Category] = []
    var categoryName:String!
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.categorylbl.text = categoryName
        // Do any additional setup after loading the view.
    }
    

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension SubCategoryController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategoryArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return subCategoryArray[indexPath.row].description.height(withConstrainedWidth: self.table.frame.size.width-32, font: UIFont(name: "SF UI Display Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)) + 90
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SubcategoryCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SubcategoryCell
        let subCat = subCategoryArray[indexPath.row]
        cell.carImage.image = UIImage(named: "subcategory\(subCat.id)")
        cell.categoryClass.text = subCat.vehicleType
        cell.subcategoryLbl.text = subCat.title
        cell.descriptionLbl.text = subCat.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        registrationCard.vehicleCategoryID = subCategoryArray[indexPath.row].id
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: .goPTO, object: nil, userInfo: nil)
        })
       
    }
    
}
