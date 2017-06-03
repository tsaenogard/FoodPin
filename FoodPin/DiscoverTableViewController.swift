//
//  DiscoverTableViewController.swift
//  FoodPin
//
//  Created by Eric Chen on 2017/4/27.
//  Copyright © 2017年 Eric Chen. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {
    
    @IBOutlet var spinner: UIActivityIndicatorView!
    var restaurants: [CKRecord] = []
    var imageCache = NSCache<CKRecordID, NSURL>()
    
    func fetchRecordsFromCloud() {
        //在更新前移除資料
        restaurants.removeAll()
        tableView.reloadData()
        //CKContainer > CKDatabase > CKRecordZone > CKRecord
        //連接容器
        let cloudContainer = CKContainer.default()
        //連接資料庫
        let publicDatabase = cloudContainer.publicCloudDatabase
        //資料過濾方式
        let predicate = NSPredicate(value: true)
        //以predicate查詢
        let query = CKQuery(recordType: "Restaurant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        //便利型
//        publicDatabase.perform(query, inZoneWith: nil) { (results, error) in
//            if error != nil {
//                print(error)
//                return
//            }
//            
//            if let results = results {
//                print("Completed the download of Restaurant data")
//                self.restaurants = results
//                OperationQueue.main.addOperation {
//                    self.tableView.reloadData()
//                    self.spinner.stopAnimating()
//                }
//            }
//        }
        

        //操作型
        //操作條件
        let queryOperation = CKQueryOperation(query: query)
        //要娶的欄位
        queryOperation.desiredKeys = ["name"]
        //執行順序
        queryOperation.queuePriority = .veryHigh
        //回傳紀錄最大數
        queryOperation.resultsLimit = 50
        //每一筆資料傳回時執行
        queryOperation.recordFetchedBlock = { (record) -> Void in
            self.restaurants.append(record)
            print(self.restaurants)
        }
        //所有資料取得後執行
        queryOperation.queryCompletionBlock = { (cursor, error) -> Void in
            if let error = error {
                print("Failed to get data from iCloud -\(error.localizedDescription)")
                return
            }
            
            print("Successfully retrieve the data from iCloud")
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
                self.spinner.stopAnimating()
                
                if let refreshControl = self.refreshControl {
                    if refreshControl.isRefreshing {
                        refreshControl.endRefreshing()
                    }
                }
            }

        }
        //執行
        publicDatabase.add(queryOperation)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //從雲端取得資料
        fetchRecordsFromCloud()
        //動態指示器啟動
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        tableView.addSubview(spinner)
        spinner.startAnimating()
        //下拉更新控制
        refreshControl = UIRefreshControl()
        refreshControl?.backgroundColor = UIColor.white
        refreshControl?.tintColor = UIColor.gray
        refreshControl?.addTarget(self, action: #selector(fetchRecordsFromCloud), for: .valueChanged)
        
        
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
        return restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        let restaurant = restaurants[indexPath.row]
        cell.textLabel?.text = restaurant.object(forKey: "name") as? String
    
//        if let image = restaurant.object(forKey: "image") {
//            let imageAsset = image as! CKAsset
//            
//            if let imageData = try? Data.init(contentsOf: imageAsset.fileURL) {
//                cell.imageView?.image = UIImage(data: imageData)
//            }
//        }
        
        //設定預設圖片
        cell.imageView?.image = UIImage(named: "photoalbum")
        
        //檢查圖片是否已存在快取中
        if let imageFileURL = imageCache.object(forKey: restaurant.recordID) {
            //從快取取得圖片
            print("Get image from cache")
            if let imageData = try? Data.init(contentsOf: imageFileURL as URL) {
                cell.imageView?.image = UIImage(data: imageData)
            }
        }else {
            //在雲端取的資料
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let fetchRecordsImageOperation = CKFetchRecordsOperation(recordIDs: [restaurant.recordID])
            fetchRecordsImageOperation.desiredKeys = ["image"]
            fetchRecordsImageOperation.queuePriority = .veryHigh
            
            fetchRecordsImageOperation.perRecordCompletionBlock = {
                (record, recordID, error) -> Void in
                if let error = error {
                    print("Failed to get restaurant image: \(error.localizedDescription)")
                    return
                }
                if let restaurant = record {
                    OperationQueue.main.addOperation {
                        if let image = restaurant.object(forKey: "image") {
                            let imageAsset = image as! CKAsset
                            
                            if let imageData = try? Data.init(contentsOf: imageAsset.fileURL) {
                                cell.imageView?.image = UIImage(data: imageData)
                            }
                            //將圖片URL存入快取中
                            self.imageCache.setObject(imageAsset.fileURL as NSURL, forKey: restaurant.recordID)
                        }
                    }
                }
            }
            publicDatabase.add(fetchRecordsImageOperation)
            
        }
        return cell
    }


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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
