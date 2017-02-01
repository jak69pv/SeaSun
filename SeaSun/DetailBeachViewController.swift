//
//  DetailBeachViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 6/12/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import CoreData

class DetailBeachViewController: UIViewController {
    
    var beach: Beach?
    
    var beachXML: BeachXMLModel?
    
    // Variable para CoreData
    let managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    // Outlets de todos los componentes
    @IBOutlet weak var beachNameLabel: UILabel!
    @IBOutlet weak var beachImageView: UIView!
    @IBOutlet weak var favSwitch: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var beachImage: UIImageView!
    
    @IBOutlet weak var changeDaysTab: UITabBar!
    @IBOutlet weak var todayButton: UITabBarItem!
    @IBOutlet weak var tomorrowButton: UITabBarItem!

    @IBOutlet weak var temperetureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var windTitle: UILabel!
    @IBOutlet weak var windData: UILabel!
    
    @IBOutlet weak var swellTitle: UILabel!
    @IBOutlet weak var swellData: UILabel!
    
    @IBOutlet weak var uvTitle: UILabel!
    @IBOutlet weak var uvData: UILabel!
    
    @IBOutlet weak var waterTempTitle: UILabel!
    @IBOutlet weak var waterTempData: UILabel!
    
    @IBOutlet weak var thermalSensTitle: UILabel!
    @IBOutlet weak var thermalSensData: UILabel!
    
    @IBAction func favSwitchAction(_ sender: UIButton) {
        if sender.currentImage == #imageLiteral(resourceName: "no_fav") {
            beach?.fav = true
            sender.setImage(#imageLiteral(resourceName: "fav"), for: .normal)
        } else {
            beach?.fav = false
            sender.setImage(#imageLiteral(resourceName: "no_fav"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        setBeachUIData(forToday: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateBeach()
        prepareFavouriteTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func prepareView() {
        beachNameLabel?.text = beach!.name!
        self.changeDaysTab.selectedItem = todayButton
        self.todayButton.title = labelsText.today
        self.todayButton.image = resizeImage(getDayImage(forToday: true), width: 30.0, height: 30.0)
        self.tomorrowButton.title = labelsText.tomorrow
        self.tomorrowButton.image = resizeImage(getDayImage(forToday: false), width: 30.0, height: 30.0)
        
        self.windTitle.text = labelsText.windTitle
        self.swellTitle.text = labelsText.swellTitle
        self.uvTitle.text = labelsText.uvTitle
        self.waterTempTitle.text = labelsText.waterTempTitle
        self.thermalSensTitle.text = labelsText.thermalSensTitle
        
        self.beachImageView.backgroundColor = UIColor.seaSunBlue
        self.mapButton.setImage(#imageLiteral(resourceName: "location_icon"), for: .normal)
        self.mapButton.imageView?.tintColor = .black
        self.mapButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.favSwitch.setImage(getIsBeachFav(), for: .normal)
        self.favSwitch.imageView?.tintColor = .black
        self.favSwitch.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        self.beachImage.image = #imageLiteral(resourceName: "val_malvarrosa_intro")
        
    }
    
    private func setBeachUIData(forToday today: Bool) {
       /* if let prediction = beachXML?.prediction?[0] {
            self.temperatureLabel?.text =  String(describing: (prediction.maxTemp)!)+"º"
            self.waterTempLabel?.text = "Water temperature: " + prediction.waterTemp!.description
            self.UVLabel?.text = "Max UV: " + String(describing: prediction.maxUV!)
        } else {
            self.tempLabel?.text =  "--º"
            self.waterTempLabel?.text = "Water temperature: Error"
            self.UVLabel?.text = "Max UV: Error"
        }
        self.stateImage.image = getStateImage(withCode: beachXML?.prediction?[0].skyState?[0].f)
        self.beachImage.image = #imageLiteral(resourceName: "val_malvarrosa_intro")
        self.nameBeachLabel?.text = (nearestBeach?.name) ?? "Error"
        self.cityBeachLabel?.text = (nearestBeach?.city) ?? "Error"
        self.windSpeedLabel?.text = "Wind: " +
            getWindString(withCode: beachXML!.prediction?[0].wind?[0].f)
        self.swellLabel?.text = "Swell: " + getSwellString(withCode: beachXML?.prediction?[0].swell?[0].f)*/
    }
    
    private func getIsBeachFav() -> UIImage {
        if let fav = self.beach?.fav {
            if fav {
                return #imageLiteral(resourceName: "fav")
            } else {
                return #imageLiteral(resourceName: "no_fav")
            }
        } else {
            return #imageLiteral(resourceName: "error")
        }
    }
    
    private func resizeImage(_ image: UIImage, width: Float, height: Float) -> UIImage {
        let size = CGSize(width: CGFloat(width),height: CGFloat(height))
        let rect = CGRect(x: 0, y: 0, width: CGFloat(height), height: CGFloat(width))
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(1.0))
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    private func updateBeach() {
        managedObjectContext?.performAndWait {
            let fetchRequest = NSFetchRequest<Beach>(entityName: "Beach")
            fetchRequest.predicate = NSPredicate(format: "webCode == %@", (self.beach?.webCode)!)
            do {
                let beachCD = try self.managedObjectContext?.fetch(fetchRequest)
                beachCD?[0].setValue(self.beach!.fav, forKey: "fav")
                try self.managedObjectContext?.save()
                
            } catch let error{
                print("Error updating beaches: \(error)")
            }
        }
    }
    
    private func prepareFavouriteTableView() {
        
        let vcCount = self.navigationController?.viewControllers.count
        if let favVC = self.navigationController?.viewControllers[vcCount! - 1] as? FavouriteBeachesTableViewController {
            favVC.fromDetailBeaches = true
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.detailToMap?:
            if let ivc = segue.destination as? MapRoadToViewController {
                ivc.goToBeach = self.beach
            }
        default:
            break
        }
    }
 

}
