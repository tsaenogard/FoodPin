//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by Eric Chen on 2017/4/5.
//  Copyright © 2017年 Eric Chen. All rights reserved.
//

import UIKit
import MapKit

class RestaurantDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   @IBOutlet var tableView: UITableView!
    
    
    @IBOutlet weak var restaurantImageView: UIImageView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
//    @IBOutlet weak var restaurantNameLabel: UILabel!
//    @IBOutlet weak var restaurantTypeLabel: UILabel!
//    @IBOutlet weak var restaurantLocationLabel: UILabel!
    
//    var restaurant = Restaurant(name: "", type: "", location: "", phone: "", image: "", isVisited: false)
    var restaurant: RestaurantMO!
    
    @IBAction func close(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func ratingButtonTapped(segue: UIStoryboardSegue) {
        if let rating = segue.identifier {
            restaurant.isVisited = true
            
            switch rating {
            case "great":
                restaurant.rating = "Absolutely love it!"
            case "good":
                restaurant.rating = "Good"
            case "dislike":
                restaurant.rating = "I dont like it"
            default:
                break
            }
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.saveContext()
        }
        tableView.reloadData()

    }
    
    func showMap() {
        performSegue(withIdentifier: "showMap", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = restaurant.name
        //tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.8)
        tableView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.2)
        
        restaurantImageView.image = UIImage(data: restaurant.image! as Data)
//        restaurantNameLabel.text = restaurant.name
//        restaurantTypeLabel.text = restaurant.type
//        restaurantLocationLabel.text = restaurant.location
        
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showMap))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(restaurant.location!) { (placemarks, error) in
            if error != nil {
                print(error!)
                return
            }
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                
                let annotation = MKPointAnnotation()
                
                if let location = placemark.location {
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                    
                    let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 250, 250)
                    self.mapView.setRegion(region, animated: false)
                }
            }
            
            
            
            
        }
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //關閉下拉隱藏狀態列功能，並開啟navigation
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantDetailTableViewCell
        cell.backgroundColor = UIColor.clear
        
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = NSLocalizedString("Name", comment: "Name Field")
            cell.valueLabel.text = restaurant.name
        case 1:
            cell.fieldLabel.text = NSLocalizedString("Type", comment: "Type Field")
            cell.valueLabel.text = restaurant.type
        case 2:
            cell.fieldLabel.text = NSLocalizedString("Location", comment: "Location Field")
            cell.valueLabel.text = restaurant.location
        case 3:
            cell.fieldLabel.text = NSLocalizedString("Phone", comment: "Phone Field")
            cell.valueLabel.text = restaurant.phone
        case 4:
            cell.fieldLabel.text = NSLocalizedString("Been here", comment: "Been Field")
            cell.valueLabel.text = (restaurant.isVisited) ? NSLocalizedString("Yes, I've been here. \(restaurant.rating)", comment: "Yes")  : NSLocalizedString("No", comment: "No")
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        }
        
        return cell
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showReview" {
            let destinationvc = segue.destination as! ReviewViewController
            destinationvc.restaurant = self.restaurant
        }
        
        if segue.identifier == "showMap" {
            let destinationvc = segue.destination as! MapViewController
            destinationvc.restaurant = self.restaurant
        }
    }
 

}
