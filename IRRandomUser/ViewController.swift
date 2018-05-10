//
//  ViewController.swift
//  IRRandomUser
//
//  Created by Ihor Rudych on 4/6/18.
//  Copyright © 2018 Ihor Rudych. All rights reserved.
//

import UIKit
import CoreData



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, SettingsViewControllerDelegate {
    
// coredata variables
    let managedObjectContext:NSManagedObjectContext? = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult>?
// fetch variables
    var size:Int = 5
    
    var user:RandomUser?
    
    var userID:UUID?
    
    var refreshCtrl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView and refresh setup
        self.refreshCtrl.tintColor = UIColor(red:0.75, green:0.52, blue:0.25, alpha:1.0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.refreshControl = refreshCtrl
        
        //grab users from CoreData
        let context:NSManagedObjectContext = self.managedObjectContext!
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.returnsObjectsAsFaults = false
        
        //since using NSFetchresultsController need to sort records
        let sectionSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        let sortDescriptors = [sectionSortDescriptor]
        request.sortDescriptors = sortDescriptors
        
        // creating the instance of NSFetchresultsController
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        aFetchedResultsController.delegate = self
        self.fetchedResultsController = aFetchedResultsController
        
        do{
            //performing the fetch
            try fetchedResultsController?.performFetch()
            
        } catch  {
            fatalError("fetchresult controller failed to fetch data \(error)")
        }
        //intiating refresh
        self.refreshCtrl.addTarget(self, action: #selector (fetchUsers), for: .valueChanged)
    }

    
//tableView overrides
    func numberOfSections(in tableView: UITableView) -> Int {
        return (fetchedResultsController?.sections?.count)!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fetchedResultsController?.sections![section].objects!.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! CustomCell
        let user = fetchedResultsController?.object(at: indexPath) as! User
        cell.nameLabel.text = user.name
        cell.emailLabel.text = "\(user.email ?? "")"
        cell.phoneLabel.text = " \(user.phone ?? "")"
        cell.adressLabel.text = user.address
        
        let img = UIImage(data:user.img!)
        cell.imageView?.image = img
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = fetchedResultsController?.object(at: indexPath) as! User
        self.userID = user.id
        self.performSegue(withIdentifier: "gotoDetail", sender: tableView.cellForRow(at: indexPath))
    }
    
    // download data from randomuser.me
    
    @objc func fetchUsers(_ sender:Any){
        
        //erase existing data in coredata
        let context:NSManagedObjectContext = self.managedObjectContext!
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do{
            let fetched = try context.fetch(request) as! [User]
            for user in fetched {
                context.delete(user)
            }
        } catch let error{
            print("failed to erase data from CoreData \(error)")
        }
        
        //grab data from randomuser.me
        let endPoint = "https://randomuser.me/api/?results=\(self.size)"
        guard let url = URL(string: endPoint) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return }
            guard let data = data else { return }
            do {
                //lets get the data into JSON
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    DispatchQueue.main.async {
                        //We go to next function to parce JSON
                        self.parseJSONResult(json: json as AnyObject)
                        
                    }}
                
            } catch let error {
                print(error)
            }
            }.resume()
    }
    private func parseJSONResult(json: AnyObject){
        let context:NSManagedObjectContext = self.managedObjectContext!
        
        //checking if results exist
        if let results = json["results"] as? [[String: AnyObject]] {
            //looping through results to get values
            for result in results {
                //variables with values
                let gender = result["gender"] as? String ?? ""
                
                let title = result["name"]?["title"] as? String ?? ""
                let firstName = result["name"]?["first"] as? String ?? ""
                let lastName = result["name"]?["last"] as? String ?? ""
                
                let street = result["location"]?["street"] as? String ?? ""
                let city = result["location"]?["city"] as? String ?? ""
                let state = result["location"]?["state"] as? String ?? ""
                let zip = Int(result["location"]?["postcode"] as? String ?? "") ?? 0
                
                let email = result["email"] as? String ?? ""
                
                let username = result["login"]?["username"] as? String ?? ""
                let password = result["login"]?["password"] as? String ?? ""
                
                let salt = result["login"]?["salt"] as? String ?? ""
                let md5 = result["login"]?["md5"] as? String ?? ""
                let sha1 = result["login"]?["sha1"] as? String ?? ""
                let sha256 = result["login"]?["sha256"] as? String ?? ""
                
                let dateOfBirth = convertDate(date: result["dob"] as? String ?? "")
                
                let dateRegistered = convertDate(date: result["registered"] as? String ?? "")
                
                let homePhone = result["phone"] as? String ?? ""
                
                let cellPhone = result["cell"] as? String ?? ""
                
                let pictureLargeURL = result["picture"]?["large"] as? String ?? ""
                let pictureMediumURL = result["picture"]?["medium"] as? String ?? ""
                let pictureThumbnailURL = result["picture"]?["thumbnail"] as? String ?? ""
                
                //assigning all the values to an instance of RandomUser class
                self.user = RandomUser(gender: gender, title: title, firstName: firstName, lastName: lastName, street: street, city: city, state: state, zip: zip, email: email, username: username, password: password, salt: salt, md5: md5, sha1: sha1, sha256: sha256, dateOfBirth: dateOfBirth, dateRegistered: dateRegistered, homePhone: homePhone, cellPhone: cellPhone, pictureLargeURL: pictureLargeURL, pictureMediumURL: pictureMediumURL, pictureThumbnailURL: pictureThumbnailURL)
                
                
                //insert users in core data
                //CoreData variables
                let id = UUID()
                let name = "\(self.user?.firstName.capitalized ?? "") \(self.user?.lastName.capitalized ?? "")"
                let usremail = "\(self.user?.email ?? "")"
                let phone = "\(self.user?.cellPhone ?? "")"
                let addr = "\(self.user?.street.capitalized ?? ""), \(self.user?.city.capitalized ?? ""), \(self.user?.state.capitalized ?? "")"
                let url = URL(string: pictureLargeURL)
                let imgdata = try? Data(contentsOf: url!)
                
                //New User insert
                let newUser:AnyObject! = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as AnyObject
                newUser.setValue(id, forKey: "id")
                newUser.setValue(name, forKey: "name")
                newUser.setValue(usremail, forKey: "email")
                newUser.setValue(phone, forKey: "phone")
                newUser.setValue(addr, forKey: "address")
                newUser.setValue(imgdata, forKey: "img")
                do {
                    try context.save()
                } catch let error {
                print("failed to save downloaded users \(error)")
                }
            }
            
            
        }
            
        else {
            print("Error! Unable to parse the JSON")
            
        }
        self.refreshCtrl.endRefreshing()
    }
    
    //pass data to controllers
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoSettings"{
            let settings:SettingsViewController = segue.destination as! SettingsViewController
            settings.size = self.size
            settings.delegate = self
        } else if segue.identifier == "gotoDetail"{
            let detail:UserDetailViewController = segue.destination as! UserDetailViewController
            detail.userID = self.userID
            
        }
    }
    //implement delegate
    func passUserBatchSize(size: Int) {
        self.size = size
        print(self.size)
        self.tableView.reloadData()
    }
    
    private func convertDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        return dateFormatter.date(from: date)!
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}

