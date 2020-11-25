//
//  ViewController.swift
//  RealmTest
//
//  Created by 최승명 on 2020/11/15.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var stuffTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var stuffPrint: UILabel!
    @IBOutlet weak var priceePrint: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var items: Results<ShoppingList>?
    var realm: Realm?
    var notificationToken: NotificationToken?
    var readItemName = [String]()
    var readItemPrice = [String]()
    
    //MARK: override func method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try? Realm()
        
        items = realm?.objects(ShoppingList.self)
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        notificationToken = items?.observe({ (change) in
            print("change : ", change)
            self.tableView.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        notificationToken?.invalidate()
    }
    
    //MARK: func method
    deinit{
        notificationToken?.invalidate()
    }
    
    func inputData(database: ShoppingList) -> ShoppingList{
        if let name = stuffTextField.text {
            database.name = name
        }
        
        if let price = priceTextField.text {
            database.price = price
        }
        return database
    }
    

    
    //MARK: Action method
    @IBAction func add(_ sender: Any) {
        try! realm?.write{
            realm?.add(inputData(database: ShoppingList()))
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        let tempObject = ShoppingList()
        tempObject.name = stuffTextField.text ?? ""
        tempObject.price = priceTextField.text ?? ""
        
        do{
            try realm?.write {
                realm?.delete(tempObject)
            }
        }catch{
            print("Error")
        }
    }
    
    @IBAction func read(_ sender: Any) {
        let result = realm?.objects(ShoppingList.self).sorted(byKeyPath: "name", ascending: true)
        let names = result?.value(forKey: "name")
        let prices = result?.value(forKey: "price")
        
        print(result ?? "값 없음")
        
    }
    
    @IBAction func update(_ sender: Any) {
        try! realm?.write{
            guard let items = items else {
                return
            }
            
            items.forEach({ (list) in
                if let name = stuffTextField.text, let price = priceTextField.text {
                    if list.name == name {
                        list.name = name
                        list.price = price
                    }
                }
            })
        }
    }
    
}

class ShoppingList: Object{
    @objc dynamic var name = ""
    @objc dynamic var price = ""
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readItemName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stuffInfo", for: indexPath)
        
        
        return cell
    }
}
