//
//  UserDetailViewController.swift
//  IRRandomUser
//
//  Created by Ihor Rudych on 4/6/18.
//  Copyright © 2018 Ihor Rudych. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//Little Detail view for each downloaded user.
class UserDetailViewController:UIViewController{
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    var userID:UUID!
    
    let managedObjectContext:NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let context:NSManagedObjectContext = self.managedObjectContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let predicate = NSPredicate(format: "id == %@", argumentArray: [self.userID!])
        request.predicate = predicate
        
        request.returnsObjectsAsFaults = false
     
        do {
            let users = try context.fetch(request) as! [User]
            let user = users.first
            self.nameLabel.text = user?.name
            self.emailLabel.text = user?.email
            self.phoneLabel.text = user?.phone
            self.addressLabel.text = user?.address
            let image = UIImage(data: (user?.img)!)
            self.userImageView.image = image
        } catch let error{
            print("failed to fetch user \(error)")
        }
        
    }
    
    
    @IBAction func donePressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}
