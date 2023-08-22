//
//  ChooseCategoryController.swift
//  TO
//
//  Created by RX Group on 17.02.2021.
//

import UIKit

class ChooseCategoryController: UIViewController {
    
    struct MainCategory{
        var title:String = ""
        var image:String = ""
    }
    
    var categoryArray:[MainCategory] = [MainCategory(title: "Категория А", image: "categoryA"),MainCategory(title: "Категория B", image: "categoryB"),MainCategory(title: "Категория C", image: "categoryC"),MainCategory(title: "Категория D", image: "categoryD"),MainCategory(title: "Категория E", image: "categoryE")]
    
    var subCategoryArray:[Category] = []
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print()
        if let data = UserDefaults.standard.value(forKey:"category") as? Data {
            self.subCategoryArray = try! PropertyListDecoder().decode(Array<Category>.self, from: data)
            self.collectionView.reloadData()
        }else{
            getRequest(URLString: mainDomen + "/api/v1/Vehicles/categories", completion: {
                result in
                DispatchQueue.main.async {
                    do {
                        //сериализация справочника в Data, чтобы декодировать ее в структуру
                       let jsonData = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                       self.subCategoryArray = try! JSONDecoder().decode([Category].self, from: jsonData)
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.subCategoryArray), forKey:"category")
                        self.collectionView.reloadData()
                    }catch{

                    }
                }
            })
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.goPto), name: .goPTO, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    
    @IBAction func chooseRegion(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goPto(){
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ptoVC") as! PTOController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension ChooseCategoryController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.categoryArray.count > 0 ? 5:0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:CategoryCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "category", for: indexPath) as! CategoryCollectionCell
            cell.categoryImage.image = UIImage(named:categoryArray[indexPath.row].image)
            cell.categoryName.text = categoryArray[indexPath.row].title
            cell.shadowDecorate()
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat = self.collectionView.frame.size.width/2 - 16
        let height : CGFloat = 96
      
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SubCategoryNavVC") as! SubCategoryNavigationController
        let presentationController = SheetModalPresentationController(presentedViewController: viewController,
                                                                              presenting: self,
                                                                              isDismissable: true)
        
        viewController.transitioningDelegate = presentationController
        viewController.modalPresentationStyle = .custom
        let rootViewController = viewController.viewControllers.first as! SubCategoryController
        rootViewController.subCategoryArray = subCategoryArray.filter({$0.vehicleCategoryID == indexPath.row+1})
        rootViewController.categoryName = categoryArray[indexPath.row].title
        self.present(viewController, animated: true)
    }
}

extension UICollectionViewCell {
    func shadowDecorate() {
        let radius: CGFloat = 5
        contentView.layer.cornerRadius = radius
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true
    
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 15.0
        layer.shadowOpacity = 0.13
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        layer.cornerRadius = radius
    }
}
