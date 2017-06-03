//
//  WalkthroughContentViewController.swift
//  FoodPin
//
//  Created by Eric Chen on 2017/4/25.
//  Copyright © 2017年 Eric Chen. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class WalkthroughContentViewController: UIViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var forwardBtn: UIButton!
    
    
    @IBOutlet weak var Btns: UIStackView!
    
    
    
    @IBOutlet weak var coreDataBtn: UIButton!
    @IBOutlet weak var cloudBtn: UIButton!
    
    var restaurantOriginal: [Restaurant] =
        [
            Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop", location: "G/F, 72 Po Hing Fong, Sheung Wan, Hong Kong", phone: "232-923423", image: "cafedeadend.jpg", isVisited: false),
            Restaurant(name: "Homei", type: "Cafe", location: "Shop B, G/F, 22-24A Tai Ping San Street SOHO, Sheung Wan, Hong Kong", phone: "348-233423", image: "homei.jpg", isVisited: false),
            Restaurant(name: "Teakha", type: "Tea House", location: "Shop B, 18 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", phone: "354-243523", image: "teakha.jpg", isVisited: false),
            Restaurant(name: "Cafe loisl", type: "Austrian / Causual Drink", location: "Shop B, 20 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", phone: "453-333423", image: "cafeloisl.jpg", isVisited: false),
            Restaurant(name: "Petite Oyster", type: "French", location: "24 Tai Ping Shan Road SOHO, Sheung Wan, Hong Kong", phone: "983-284334", image: "petiteoyster.jpg", isVisited: false),
            Restaurant(name: "For Kee Restaurant", type: "Bakery", location: "Shop J-K., 200 Hollywood Road, SOHO, Sheung Wan, Hong Kong", phone: "232-434222", image: "forkeerestaurant.jpg", isVisited: false),
            Restaurant(name: "Po's Atelier", type: "Bakery", location: "G/F, 62 Po Hing Fong, Sheung Wan, Hong Kong", phone: "234-834322", image: "posatelier.jpg", isVisited: false),
            Restaurant(name: "Bourke Street Backery", type: "Chocolate", location: "633 Bourke St Sydney New South Wales 2010 Surry Hills", phone: "982-434343", image: "bourkestreetbakery.jpg", isVisited: false),
            Restaurant(name: "Haigh's Chocolate", type: "Cafe", location: "412-414 George St Sydney New South Wales", phone: "734-232323", image: "haighschocolate.jpg", isVisited: false),
            Restaurant(name: "Palomino Espresso", type: "American / Seafood", location: "Shop 1 61 York St Sydney New South Wales", phone: "872-734343", image: "palominoespresso.jpg", isVisited: false),
            Restaurant(name: "Upstate", type: "American", location: "95 1st Ave New York, NY 10003", phone: "343-233221", image: "upstate.jpg", isVisited: false),
            Restaurant(name: "Traif", type: "American", location: "229 S 4th St Brooklyn, NY 11211", phone: "985-723623", image: "traif.jpg", isVisited: false),
            Restaurant(name: "Graham Avenue Meats", type: "Breakfast & Brunch", location: "445 Graham Ave Brooklyn, NY 11211", phone: "455-232345", image: "grahamavenuemeats.jpg", isVisited: false),
            Restaurant(name: "Waffle & Wolf", type: "Coffee & Tea", location: "413 Graham Ave Brooklyn, NY 11211", phone: "434-232322", image: "wafflewolf.jpg", isVisited: false),
            Restaurant(name: "Five Leaves", type: "Coffee & Tea", location: "18 Bedford Ave Brooklyn, NY 11222", phone: "343-234553", image: "fiveleaves.jpg", isVisited: false),
            Restaurant(name: "Cafe Lore", type: "Latin American", location: "Sunset Park 4601 4th Ave Brooklyn, NY 11220", phone: "342-455433", image: "cafelore.jpg", isVisited: false),
            Restaurant(name: "Confessional", type: "Spanish", location: "308 E 6th St New York, NY 10003", phone: "643-332323", image: "confessional.jpg", isVisited: false),
            Restaurant(name: "Barrafina", type: "Spanish", location: "54 Frith Street London W1D 4SL United Kingdom", phone: "542-343434", image: "barrafina.jpg", isVisited: false),
            Restaurant(name: "Donostia", type: "Spanish", location: "10 Seymour Place London W1H 7ND United Kingdom", phone: "722-232323", image: "donostia.jpg", isVisited: false),
            Restaurant(name: "Royal Oak", type: "British", location: "2 Regency Street London SW1P 4BZ United Kingdom", phone: "343-988834", image: "royaloak.jpg", isVisited: false),
            Restaurant(name: "CASK Pub and Kitchen", type: "Thai", location: "22 Charlwood Street London SW1V 2DY Pimlico", phone: "432-344050", image: "caskpubkitchen.jpg", isVisited: false)
    ]
    
    @IBAction func cleanCoreData(_ sender: UIButton) {
        
    }
    
    
    @IBAction func importToCoreData(_ sender: UIButton) {
        

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {

            for rest in restaurantOriginal {
                let restaurant = RestaurantMO(context: appDelegate.persistentContainer.viewContext)
                print("Name: \(rest.name)")
                print("Type: \(rest.type)")
                print("Location: \(rest.location)")
                print("Phone: \(rest.phone)")
                print("Have you been here: \(rest.isVisited)")
                
                restaurant.name = rest.name
                restaurant.type = rest.type
                restaurant.location = rest.location
                restaurant.phone = rest.phone
                restaurant.isVisited = rest.isVisited
                if let image = UIImage(named: rest.image) {
                    let imageData = UIImagePNGRepresentation(image)!
                    restaurant.image = NSData(data: imageData)
                }
                appDelegate.saveContext()
            }
        }
        let alertController = UIAlertController(title: "成功!!", message: "CoreData資料建立成功", preferredStyle: .alert)
        let alertAction1 = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(alertAction1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func cleanCloud(_ sender: UIButton) {
        
        
    }
    
    
    @IBAction func importToiCloud(_ sender: UIButton) {
        
        let publicDatabase = CKContainer.default().publicCloudDatabase
        
        for rest in restaurantOriginal {
            let record = CKRecord(recordType: "Restaurant")
            record.setValue(rest.name, forKey: "name")
            record.setValue(rest.type, forKey: "type")
            record.setValue(rest.location, forKey: "location")
            record.setValue(rest.phone, forKey: "phone")
            
            //縮放
            let originalImage = UIImage(named: rest.image)!
            let imageData = UIImagePNGRepresentation(UIImage(named: rest.image)!)!
            let scalFactor = ( originalImage.size.width > 1024 ) ? 1024 / originalImage.size.width : 1.0
            let scaledImage = UIImage(data: imageData, scale: scalFactor)
            //寫入暫存
            let imageFilePath = NSTemporaryDirectory() + rest.image
            let imageFileURL = URL(fileURLWithPath: imageFilePath)
            try? UIImageJPEGRepresentation(scaledImage!, 0.8)?.write(to: imageFileURL)
            //轉換成asset
            let imageAsset = CKAsset(fileURL: imageFileURL)
            
            record.setValue(imageAsset, forKey: "image")
            publicDatabase.save(record, completionHandler: { (record, error) in
                if error != nil {
                    print(error!)
                }
                print(record)
                try? FileManager.default.removeItem(at: imageFileURL)
            })
        }
        let alertController = UIAlertController(title: "成功!!", message: "iCloud資料建立成功", preferredStyle: .alert)
        let alertAction1 = UIAlertAction(title: "確定", style: .default, handler: nil)
        alertController.addAction(alertAction1)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    var index = 0
    var heading = ""
    var imageFile = ""
    var content = ""
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        switch index {
        case 0...2:
            let pageViewController = parent as! WalkthroughPageViewController
            pageViewController.forward(index: index)
        case 3:
            UserDefaults.standard.set(true, forKey: "hasViewedWalkthrough")
            
            if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                let bundleIdentifier = Bundle.main.bundleIdentifier
                let shortcutItem1 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenFavorites", localizedTitle: "Show Favorites", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "favorite-shortcut"), userInfo: nil)
                let shortcutItem2 = UIApplicationShortcutItem(type: "\(bundleIdentifier).OpenDiscover", localizedTitle: "Discover restaurants", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(templateImageName: "discover-shortcut"), userInfo: nil)
                let shortcutItem3 = UIApplicationShortcutItem(type: "\(bundleIdentifier).NewRestaurant", localizedTitle: "New Restaurant", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
                UIApplication.shared.shortcutItems = [shortcutItem1, shortcutItem2, shortcutItem3]
            }
            
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        headingLabel.text = heading
        contentLabel.text = content
        contentImageView.image = UIImage(named: imageFile)
        pageControl.currentPage = index
        for view in Btns.arrangedSubviews {
            view.layer.borderWidth = 3
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor.black.cgColor
        }
        Btns.isHidden = true

        
//        switch index {
//        case 0...1:
//            forwardBtn.setTitle("NEXT", for: .normal)
//        case 2:
//            forwardBtn.setTitle("DONE", for: .normal)
//        default:
//            break
//        }

        if case 0...2 = index {
            forwardBtn.setTitle("NEXT", for: .normal)
        }else if case 3 = index {
            forwardBtn.setTitle("DONE", for: .normal)
            contentImageView.isHidden = true
            Btns.isHidden = false
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
