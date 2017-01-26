//
//  DetailBeachViewController.swift
//  SeaSun
//
//  Created by Alberto Ramis on 6/12/16.
//  Copyright © 2016 Alberto Ramis. All rights reserved.
//

import UIKit

class DetailBeachViewController: UIViewController {
    
    var beach: Beach?
    
    var beachXML: BeachXMLModel?
    
    @IBOutlet weak var beachNameLabel: UILabel!

    @IBOutlet weak var changeDaysTab: UITabBar!
    @IBOutlet weak var todayButton: UITabBarItem!
    @IBOutlet weak var tomorrowButton: UITabBarItem!
    
    @IBOutlet weak var temperatureLabel: UIStackView!
    @IBOutlet weak var weatherIcon: UIStackView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
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
        
    }
    
    private func setBeachUIData() {
        if let prediction = beachXML?.prediction?[0] {
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
        self.swellLabel?.text = "Swell: " + getSwellString(withCode: beachXML?.prediction?[0].swell?[0].f)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
