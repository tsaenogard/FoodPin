//
//  ResaurantTableViewController.swift
//  FoodPin
//
//  Created by Eric Chen on 2017/4/3.
//  Copyright © 2017年 Eric Chen. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import UserNotifications

class ResaurantTableViewController: UITableViewController {
    
//   //狀態列隱藏
//   override var prefersStatusBarHidden: Bool {
//        return true
//    }
//    //狀態列顏色
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    //將資料存成class格式
    //較複雜但能及時獲取
    var fetchResultController: NSFetchedResultsController<RestaurantMO>!
    
    var searchController: UISearchController!
    
    var searchResults: [RestaurantMO] = []
    var restaurants:[RestaurantMO] = []
    
    @IBAction func description(_ sender: UIBarButtonItem) {
        if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController") as? WalkthroughPageViewController {
            present(pageViewController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        
    }
    

    
    func filterContent(for searchText: String) {
        searchResults = restaurants.filter({ (restaurant) -> Bool in
            if let name = restaurant.name, let location = restaurant.location {
                let isMatch = name.localizedCaseInsensitiveContains(searchText) || location.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }

            return false
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
            return
        }
        if let pageViewController = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController") as? WalkthroughPageViewController {
            present(pageViewController, animated: true, completion: nil)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                //執行讀取結果
                try fetchResultController.performFetch()
                if let fetchObjects = fetchResultController.fetchedObjects {
                    restaurants = fetchObjects
                }
            } catch {
                print(error)
            }
        }
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false

        
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: view)
        }
        
        prepareNotiification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //開啟下拉隱藏狀態列功能
        navigationController?.hidesBarsOnSwipe = true
//        //較簡單方式即載入時即獲取資料庫
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            let request: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
//            let context = appDelegate.persistentContainer.viewContext
//            do {
//                restaurants = try context.fetch(request)
//            } catch {
//                print(error)
//            }
//        }
    }
    
    
    func prepareNotiification() {
        if restaurants.count <= 0 {
            return
        }
        let randomNum = Int(arc4random_uniform(UInt32(restaurants.count)))
        let suggestedRestaurant = restaurants[randomNum]
        
        let content = UNMutableNotificationContent()
        content.title = "Restaurant Recommendation"
        content.subtitle = "Try new food today"
        content.body = "I recommend you to check out \(suggestedRestaurant.name!). Yhe restaurant is one of your favorites. It is located at \(suggestedRestaurant.location!). Would you like to give it a try?"
        content.sound = UNNotificationSound.default()
        
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-restaurant.jpg")
        
        if let image = UIImage(data: suggestedRestaurant.image! as Data) {
            try? UIImageJPEGRepresentation(image, 1.0)?.write(to: tempFileURL)
            if let restaurantImage = try? UNNotificationAttachment(identifier: "restaurantImage", url: tempFileURL, options: nil) {
                content.attachments = [restaurantImage]
            }
        }
        let categoryIdentifer = "foodpin.restaurantaction"
        let makeReservationAction = UNNotificationAction(identifier: "foodpin.makeReservation", title: "Reserve a table", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "foodpin.cancel", title: "Later", options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifer, actions: [makeReservationAction, cancelAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = categoryIdentifer
        
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "foodpin.restaurantSuggestion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if searchController.isActive {
            return searchResults.count
        }else {
            return restaurants.count

        }
        
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ResaurantTableViewCell
        
        let restaurant = (searchController.isActive) ? searchResults[indexPath.row] : restaurants[indexPath.row]
        
        cell.nameLabel.text = restaurant.name
        //cell.thumbnailImageView.image = UIImage(named: restaurants[indexPath.row].image)
        cell.thumbnailImageView.image = UIImage(data: restaurant.image! as Data)
        cell.typrLabel.text = restaurant.type
        cell.locationLabel.text = restaurant.location
        cell.accessoryType = restaurant.isVisited ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //跳出alert標記去過與否
        let opionMenu = UIAlertController(title: nil, message: "What do you want to do?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        opionMenu.addAction(cancelAction)
    
        let callActionHandler = { (action: UIAlertAction) -> Void in
            let alertMessage = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later. ", preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
        
        let callAction = UIAlertAction(title: "Call" + "123-000-\(indexPath.row)", style: .default, handler: callActionHandler)
        opionMenu.addAction(callAction)
        
        let checkInAction = UIAlertAction(title: restaurants[indexPath.row].isVisited ? "Uncheck" : "Check in", style: .default) { (action: UIAlertAction) -> Void in
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = self.restaurants[indexPath.row].isVisited ? .none : .checkmark
            self.restaurants[indexPath.row].isVisited = !(self.restaurants[indexPath.row].isVisited)
            
        }
        opionMenu.addAction(checkInAction)
        self.present(opionMenu, animated: true, completion: nil)
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if searchController.isActive {
            return false
        }else {
            return true
        }
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //當有用editActionsForRowAt，這方法會被取代
        if editingStyle == .delete {
            
            restaurants.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
//        else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//            let alertAdd = UIAlertController(title: "Add", message: "please add insert data", preferredStyle: .alert)
//            alertAdd.addTextField(configurationHandler: { (name: UITextField) in
//                name.placeholder = "name"
//            })
//            alertAdd.addTextField(configurationHandler: { (type: UITextField) in
//                type.placeholder = "type"
//            })
//            alertAdd.addTextField(configurationHandler: { (location: UITextField) in
//                location.placeholder = "location"
//            })
//            alertAdd.addAction(UIAlertAction(title: "OK", style: .default, handler: { (
//                action: UIAlertAction) in
//                if let name = alertAdd.textFields?[0].text {
//                    if let type = alertAdd.textFields?[1].text {
//                        if let location = alertAdd.textFields?[2].text {
//                            self.restaurantNames.append(name)
//                            self.restaurantTypes.append(type)
//                            self.restaurantLocations.append(location)
//                            
//                            tableView.insertRows(at: [indexPath], with: .bottom)
//                        }
//                    }
//                }
//                self.present(alertAdd, animated: true, completion: nil)
//
//            }))
//            alertAdd.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//            
//        }    
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let shareAction = UITableViewRowAction(style: .default, title: "share") { (action, indexPath) in
            let defaultText = "Just checking in at" + self.restaurants[indexPath.row].name!
            
//            if let imageTOShare = UIImage(named: self.restaurants[indexPath.row].image)
                if let imageToShare = UIImage(data: self.restaurants[indexPath.row].image! as Data)
            {
                let activityController = UIActivityViewController(activityItems: [defaultText, imageToShare], applicationActivities: nil)
                self.present(activityController, animated: true, completion: nil)
            }
            
            
            
            
            
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "delete") { (action, indexPath) in
            
//            self.restaurants.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let context = appDelegate.persistentContainer.viewContext
                let restaurantToDelete = self.fetchResultController.object(at: indexPath)
                context.delete(restaurantToDelete)
                appDelegate.saveContext()
            }
        }
        
        shareAction.backgroundColor = UIColor.green
        deleteAction.backgroundColor = UIColor.lightGray
        return [deleteAction, shareAction]
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! RestaurantDetailViewController
                destinationController.restaurant = (searchController.isActive) ? searchResults[indexPath.row] : restaurants[indexPath.row]
                
            }
        }
    }
 

}

extension ResaurantTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        if let fetchObjects = controller.fetchedObjects {
            restaurants = fetchObjects as! [RestaurantMO]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

extension ResaurantTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
}

extension ResaurantTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
        guard let restaurantDetailViewController = storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailViewController") as? RestaurantDetailViewController else { return nil }
        
        let selectedRestaurant = restaurants[indexPath.row]
        restaurantDetailViewController.restaurant = selectedRestaurant
        restaurantDetailViewController.preferredContentSize = CGSize(width: 0.0, height: 450.0)
        previewingContext.sourceRect = cell.frame
        return restaurantDetailViewController
        
    }
}










