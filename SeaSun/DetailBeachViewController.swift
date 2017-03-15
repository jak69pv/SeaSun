//
//  DetailBeachViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 6/12/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit
import CoreData

class DetailBeachViewController: UIViewController, UITabBarDelegate {
    
    var beach: Beach?
    
    var beachXML: BeachXMLModel?
    
    var prediction: [Weather]?
    
    var showToday: Bool?
    
    // Variable para CoreData
    var managedObjectContext: NSManagedObjectContext?
    
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
        self.showToday = true
        self.changeDaysTab.delegate = self
        prediction = Weather.getPrediction(context: managedObjectContext!, beach: beach!)
        if prediction == nil && isInternetAvailable(){
            DispatchQueue.global(qos: .background).async {
                self.getAemetXML(beachCode: (self.beach?.webCode)!)
                DispatchQueue.main.sync {
                    self.prediction = Weather.addWeatherPrediction(context: self.managedObjectContext!, beach: self.beach!, beachData: self.beachXML!)
                    self.setBeachUIData(forToday: self.showToday!)

                }
            }
        } else {
            print(prediction?[0])
            if prediction?.count == 1 { tomorrowButton.isEnabled = false }
            setBeachUIData(forToday: showToday!)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateBeach()
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
        
        self.todayButton.tag = 0
        self.tomorrowButton.tag = 1
        
    }
    
    private func setBeachUIData(forToday today: Bool) {
        var showPrediction: Weather?
        var isMorning: Bool
        if today {
            showPrediction = self.prediction?[0]
            let hour = Calendar.current.component(.hour, from: Date())
            isMorning = (hour < 13 && hour > 0) ? true : false
        } else {
            showPrediction = self.prediction?[1]
            isMorning = true
        }
        if let checkedPrediction = showPrediction {
            if isMorning {
                self.weatherIcon.image = getStateImage(withCode: Int(checkedPrediction.skyState1))
                self.windData?.text = getWindString(withCode: Int(checkedPrediction.wind1))
                self.swellData?.text = getSwellString(withCode: Int(checkedPrediction.swell1))

            } else {
                self.weatherIcon.image = getStateImage(withCode: Int(checkedPrediction.skyState2))
                self.windData?.text = getWindString(withCode: Int(checkedPrediction.wind2))
                self.swellData?.text = getSwellString(withCode: Int(checkedPrediction.swell2))
            }
            self.temperetureLabel?.text = "\(checkedPrediction.maxTemp)º"
            self.uvData?.text = "\(checkedPrediction.maxUV)"
            self.waterTempData?.text = "\(checkedPrediction.waterTemp)º"
            self.thermalSensData?.text = getTermSensationString(withCode:  Int(checkedPrediction.termSensation))
        } else {
            self.temperetureLabel?.text = "--º"
            self.weatherIcon.image = #imageLiteral(resourceName: "error")
            self.windData?.text = getWindString(withCode: -1)
            self.swellData?.text = getSwellString(withCode: -1)
            self.uvData?.text = "-"
            self.waterTempData?.text = "--º"
            self.thermalSensData?.text = getTermSensationString(withCode: -1)
        }
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
        managedObjectContext?.perform {
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

    
    private func getAemetXML(beachCode: String) {
        beachXML = BeachXMLModel(with: beachCode)
        beachXML?.parser()
    }
    
    // Funcion para gestionar cuando se pulsa un boton de la TabBar
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        switch item.tag {
        case 0:
            self.showToday = true
        case 1:
            self.showToday = false
        default:
            break
        }
        setBeachUIData(forToday: self.showToday!)
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
