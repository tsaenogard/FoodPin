//
//  AddRestaurantController.swift
//  FoodPin
//
//  Created by Eric Chen on 2017/4/21.
//  Copyright © 2017年 Eric Chen. All rights reserved.
//

import UIKit
import CoreData
import CloudKit


class AddRestaurantController: UITableViewController {
    
    var isVisited: Bool = true
    var restaurant: RestaurantMO!

    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var noBtn: UIButton!
    
    func saveRecordToCloud(restaurant: RestaurantMO!) -> Void {
        let record = CKRecord(recordType: "Restaurant")
        record.setValue(restaurant.name, forKey: "name")
        record.setValue(restaurant.type, forKey: "type")
        record.setValue(restaurant.location, forKey: "location")
        record.setValue(restaurant.phone, forKey: "phone")
        
        let imageData = restaurant.image as! Data
        
        let originalImage = UIImage(data: imageData)!
        let scalingFactor = (originalImage.size.width > 1024) ? 1024 / originalImage.size.width : 1.0
        let scaledImage = UIImage(data: imageData, scale: scalingFactor)
        //寫入暫存
        let imageFilePath = NSTemporaryDirectory() + restaurant.name!
        let imageFileURL = URL(fileURLWithPath: imageFilePath)
        //壓縮圖片
        try? UIImageJPEGRepresentation(scaledImage!, 0.8)?.write(to: imageFileURL)
        //轉換為上傳的類型
        let imageAsset = CKAsset(fileURL: imageFileURL)
        record.setValue(imageAsset, forKey: "image")
        //連接資料庫
        let publicDatabase = CKContainer.default().publicCloudDatabase
        publicDatabase.save(record) { (record, error) in
            //移除暫存檔
            try? FileManager.default.removeItem(at: imageFileURL)
        }
    }
    
    @IBAction func toggleBeenHereBtn(_ sender: UIButton) {
        if sender == yesBtn {
            isVisited = true
            yesBtn.backgroundColor = .red
            noBtn.backgroundColor = .lightGray
        }else if sender == noBtn {
            isVisited = false
            yesBtn.backgroundColor = .lightGray
            noBtn.backgroundColor = .red
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        if nameTextField.text == "" || typeTextField.text == "" || locationTextField.text == "" || phoneTextField.text == "" {
            let alertController = UIAlertController(title: "Oops", message: "We can't proceed because one of the field is blank. Please note that all field are required.", preferredStyle: .alert)
            let alertAction1 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction1)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        print("Name: \(nameTextField.text!)")
        print("Type: \(typeTextField.text!)")
        print("Location: \(locationTextField.text!)")
        print("Phone: \(phoneTextField.text!)")
        print("Have you been here: \(isVisited)")
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            restaurant = RestaurantMO(context: appDelegate.persistentContainer.viewContext)
            restaurant.name = nameTextField.text
            restaurant.type = typeTextField.text
            restaurant.location = locationTextField.text
            restaurant.phone = phoneTextField.text
            restaurant.isVisited = isVisited
            //將photoimage的圖片用UIImagePNGRepresentation讀成data形式
            if let restaurantImage = photoImageView.image {
                if let imageData = UIImagePNGRepresentation(restaurantImage) {
                    restaurant.image = NSData(data: imageData)
                }
            }
            print("Saving data to context...")
            appDelegate.saveContext()
        }
        saveRecordToCloud(restaurant: restaurant)
        
        //performSegue(withIdentifier: "unwindToHomeScreen", sender: self)
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddRestaurantController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //圖片代理器將圖片讀到UI元件上
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selsctedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoImageView.image = selsctedImage
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.clipsToBounds = true
            
        }
        let leadingConstraint = NSLayoutConstraint(item: photoImageView, attribute: .leading, relatedBy: .equal, toItem: photoImageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: photoImageView, attribute: .trailing, relatedBy: .equal, toItem: photoImageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: photoImageView, attribute: .top, relatedBy: .equal, toItem: photoImageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: photoImageView, attribute: .bottom, relatedBy: .equal, toItem: photoImageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        //然後返回
        dismiss(animated: true, completion: nil)
    }
    
}

