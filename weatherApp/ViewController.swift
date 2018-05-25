//
//  ViewController.swift
//  weatherApp
//
//  Created by Max Bilan on 5/23/18.
//  Copyright © 2018 Max Bilan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let urlString = "https://api.apixu.com/v1/current.json?key=4be1d7f4c7644aafbbe141625182305&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))"
        let textFromSearchBar = searchBar.text!
        let url = URL(string: urlString)
        
        var locationName: String?
        var temperature: Double?
        var errorHasOccured: Bool = false
        
        var iconURL: URL?
        
        var iconString: String?
        
        if textFromSearchBar == "Dasha" {
            errorHasOccured = true
        }


        let task = URLSession.shared.dataTask(with: url!) {[weak self] (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: AnyObject]
                
                if let _ = json["error"] {
                    errorHasOccured = true
                }
                
                if let location = json["location"] {
                    locationName = location["name"] as? String
                    if locationName == "dasha" {
                        locationName = "Love you :)"
                    }
                }
                
                if let current = json["current"] {
                    temperature = current["temp_c"] as? Double
                    
                    let condition = current["condition"] as! [String: AnyObject]
                
                    if let icon = condition["icon"] {
                        iconString = (icon as! String)
                    }
                }
                
                
//                let current = json["current"]
//                let condition = current!["condition"]
//                let iconRawURL = condition["icon"]
                
                ////////
                
                var urlString = "https:"
                urlString += iconString!
                
//                urlString = "https://tinypng.com/images/example-shrunk.png"
                
                iconURL = URL(string: urlString)!
                
                let session = URLSession(configuration: .default)
                
                var image = UIImage()
                
                print(1)
                
                let downloadPicTask = session.dataTask(with: iconURL!) { (data, response, error) in
                    // The download has finished.
                    if let e = error {
                        print("Error downloading cat picture: \(e)")
                        print(2)
                    } else {
                        print(3)
                        // No errors found.
                        // It would be weird if we didn't have a response, so check for that too.
                        if let res = response as? HTTPURLResponse {
                            print("Downloaded cat picture with response code \(res.statusCode)")
                            if let imageData = data {
                                // Finally convert that Data into an image and do what you wish with it.
                                image = UIImage(data: imageData)!
                                DispatchQueue.main.sync {
                                    self?.imageView.image = image
                                }
                                
                                print(3)
                                // Do something with your image.
                            } else {
                                print("Couldn't get image: Image is nil")
                            }
                        } else {
                            print("Couldn't get response code for some reason")
                        }
                    }
                }
                
                print(4)
                
                
                downloadPicTask.resume()
                
                DispatchQueue.main.sync {
                    if errorHasOccured {
                        if textFromSearchBar == "Dasha" {
                            self?.cityLabel.text = "Love you :)"
                            self?.temperatureLabel.text = "1000 °C"
                        } else {
                            self?.cityLabel.text = "Uncnown city"
                            self?.temperatureLabel.text = ""
                        }
                        
                    } else {
                        self?.cityLabel.text = locationName
                        self?.temperatureLabel.text = "\(temperature!) °C"
//                        self?.imageView.image = image
//                        self?.imageView!.addSubview(image)
                    }
                    
                }
                
            }
            catch let jsonError {
                print(jsonError)
            }
            
        }
        
        task.resume()
    }
}

