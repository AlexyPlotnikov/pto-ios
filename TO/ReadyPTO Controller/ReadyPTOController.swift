//
//  ReadyPTOController.swift
//  TO
//
//  Created by RX Group on 20.02.2021.
//

import UIKit

class ReadyPTOController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: JMMaskTextField!
    @IBOutlet weak var adressLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var vehicleLbl: UILabel!
    var idCard:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeAll), name: .closeAll, object: nil)
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView=false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        nameTextField.becomeFirstResponder()
        nameTextField.text = registrationCard.clientName
        nameTextField.delegate = self
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Ваше имя",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(displayP3Red: 162/255, green: 162/255, blue: 162/255, alpha: 1)])
        let mask = JMStringMask(mask: "+7 (000) 000 00 00")
        let maskedString = mask.mask(string: registrationCard.clientPhone)
        phoneTextField.text = maskedString
         
        phoneTextField.delegate = self
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "Ваш номер телефона",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(displayP3Red: 162/255, green: 162/255, blue: 162/255, alpha: 1)])
        self.addToolBarTextfield(textField: phoneTextField)
        self.setupUI()
    }
    @objc func closeAll(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleTap(){
        self.view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }

    func setupUI(){
        let formatterHours = DateFormatter()
            formatterHours.dateFormat = "HH:mm"
        let formatterDays = DateFormatter()
            formatterDays.dateFormat = "dd.MM"
        let formaterDate = DateFormatter()
            formaterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
             

        self.adressLbl.text = currentPTO.address
        self.dateLbl.text = formatterDays.string(from: formaterDate.date(from: registrationCard.dateTime)!)
        self.timeLbl.text = formatterHours.string(from: formaterDate.date(from: registrationCard.dateTime)!)
        self.vehicleLbl.text = registrationCard.vehicleMark + " " + registrationCard.vehicleModel
    }

    func addToolBarTextfield(textField:UITextField){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItem.Style.done, target: self, action: #selector(handleTap))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func done(_ sender: Any) {
        
        if(registrationCard.clientName == ""){
            setMessage(text: "Пожалуйста, укажите Ваше имя", controller: self)
        }else if(registrationCard.clientPhone == ""){
            setMessage(text: "Пожалуйста, укажите Ваш номер телефона", controller: self)
        }else{
            postRequest(JSON: registrationCard.asDictionary, URLString: mainDomen + "/api/v1/Maintenances", completion: {
                result in
                DispatchQueue.main.async {
                    if(result["id"] as? Int != nil){
                        self.idCard = result["id"] as! Int
                    }
                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "resultVC") as! ResultController
                    viewController.idCard = self.idCard
                    viewController.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(viewController, animated: true, completion: nil)
                }
                
            })
        }
    }
    
    
}

extension ReadyPTOController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.handleTap()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == nameTextField){
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            registrationCard.clientName = currentText.replacingCharacters(in: stringRange, with: string)
        }else{
            registrationCard.clientPhone = (textField as! JMMaskTextField).unmaskedText!+string
            
            if(registrationCard.clientPhone.count == 1){
                if(registrationCard.clientPhone == "8"){
                   return false
                }
            }
            if(registrationCard.clientPhone.count>1){
                registrationCard.clientPhone.remove(at: registrationCard.clientPhone.startIndex)
            }
            if(registrationCard.clientPhone.count>=11){
                registrationCard.clientPhone.remove(at: registrationCard.clientPhone.index(before: registrationCard.clientPhone.endIndex))
            }
        }
        return true
    }
    
}
