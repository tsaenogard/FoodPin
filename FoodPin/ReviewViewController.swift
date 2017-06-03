//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by Eric Chen on 2017/4/18.
//  Copyright © 2017年 Eric Chen. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var containerImageView: UIImageView!
    
    
    @IBOutlet weak var closeBtn: UIButton!
    
    
//    var restaurant = Restaurant(name: "", type: "", location: "", phone: "", image: "", isVisited: false)
    var restaurant: RestaurantMO?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.containerView.transform = CGAffineTransform.identity
        }, completion: nil)
//        UIView.animate(withDuration: 0.3) {
//            self.containerView.transform = CGAffineTransform.identity
//        }
        
        UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseInOut, animations: {
            self.closeBtn.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //建立模糊效果
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.image = UIImage(data: restaurant?.image as! Data)
        containerImageView.image = UIImage(data: restaurant?.image as! Data)
        backgroundImageView.addSubview(blurEffectView)
        
//        containerView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
//        containerView.transform = CGAffineTransform.init(translationX: 0, y: -1000)
        
        let scaleTransform = CGAffineTransform.init(scaleX: 0, y: 0)
        let translateTransform = CGAffineTransform.init(translationX: 0, y: -1000)
        let combineTransform = scaleTransform.concatenating(translateTransform)
        containerView.transform = combineTransform
        
        closeBtn.transform = CGAffineTransform.init(translationX: 1000, y: 0)
        
        
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
