//
//  ViewController.swift
//  RestaurantsInALocation
//
//  Created by Sanket  Ray on 06/11/17.
//  Copyright © 2017 Sanket  Ray. All rights reserved.
//

import UIKit
import SDWebImage


class ViewController: UIViewController{
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet var sortingList: UIView!
    
    
    var restaurants = [Restaurant]()
    var start = 0
    var sort = "rating"
    var order = "desc"
    
    static var navigationTitleButton = UIButton(type: .system)
    static var locationLatitude = "40.742051"
    static var locationLongitude = "-74.004821"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getListOfRestaurants(start : start, lat: ViewController.locationLatitude, long: ViewController.locationLongitude)
        createNavigationTitleButton()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(ViewController.locationLatitude,ViewController.locationLongitude,"🍋")
        start = 0
        restaurants = [Restaurant]()
        table.reloadData()
        getListOfRestaurants(start: start, lat: ViewController.locationLatitude, long: ViewController.locationLongitude)
    }
    
    @IBAction func searchAfterSorting(_ sender: Any) {
        print(restaurants.count)
        start = 0
        restaurants = [Restaurant]()
        table.reloadData()
        getListOfRestaurants(start: start, lat: ViewController.locationLatitude, long: ViewController.locationLongitude)
    }
    
    @IBAction func sortingOptionTapped(_ sender: UIButton) {
        sortByButton.setTitle(sender.currentTitle, for: .normal)
        
        if sender.currentTitle! == "Rating High to Low" {
            sort = "rating"
            order = "desc"
        }
        else if sender.currentTitle! == "Price High to Low" {
            sort = "cost"
            order = "desc"
        }
        else if sender.currentTitle! == "Rating Low to High" {
            sort = "rating"
            order = "asc"
        }
        else if sender.currentTitle! == "Price Low to High" {
            sort = "cost"
            order = "asc"
        }
        
        UIView.animate(withDuration: 0.2) {
            self.sortingList.removeFromSuperview()
        }
    }
    
    
    @IBAction func sortBy(_ sender: Any) {
        let centerX = (sortByButton.frame.origin.x + (sortByButton.frame.width/2))
        let centerY = (sortByButton.frame.height + (sortingList.frame.height/2))
        
        UIView.animate(withDuration: 0.2) {
            self.view.addSubview(self.sortingList)
            self.sortingList.center = CGPoint(x: centerX, y: centerY)
        }
    }
    
    func createNavigationTitleButton() {
        ViewController.navigationTitleButton.setImage(UIImage(named: "markerIcon"), for: .normal)
        ViewController.navigationTitleButton.setTitle("Location will be displayed here", for: .normal)
        ViewController.navigationTitleButton.setTitleColor(UIColor.white, for: .normal)
        ViewController.navigationTitleButton.titleLabel?.font = UIFont(name: "Avenir Next", size: 16)
        ViewController.navigationTitleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        ViewController.navigationTitleButton.addTarget(self, action: #selector(self.selectLocation(button:)), for: .touchUpInside)
        
        self.navigationItem.titleView = ViewController.navigationTitleButton
    }
    
    @objc func selectLocation(button: UIButton) {
        performSegue(withIdentifier: "selectLocation", sender: self)
    }
    
    
    func getListOfRestaurants(start: Int, lat: String, long: String) {
        print("Finding restaurants")
        self.start += 20
        let request = NSMutableURLRequest(url: URL(string: "https://developers.zomato.com/api/v2.1/search?start=\(start)&lat=\(lat)&lon=\(long)&sort=\(sort)&order=\(order)")!)
        request.addValue("107aa037e7df67d13089a966c701acc0", forHTTPHeaderField: "user-key")
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard error == nil else{
                print("error while requesting data")
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("status code was other than 2xx")
                return
            }
            guard let data = data else {
                print("request for data failed")
                return
            }
            
            let parsedResult : [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            }catch {
                print("error parsing data")
                return
            }

            guard let nearbyRes = parsedResult["restaurants"] as? [AnyObject] else {
                print("Could not get restaurant list")
                return
            }
//            iterate over all the available restaurants for the location
            for res in nearbyRes {
                guard let rest = res["restaurant"] as? [String:AnyObject] else {
                    print("Could not get restaurant")
                    return
                }
                guard let r = rest["R"] as? [String:AnyObject] else {
                    print("Could not get restaurant id")
                    return
                }
//                 1.  ResID
                guard let resID = r["res_id"] as? Int else {
                    print("Could not get ID")
                    return
                }
//                2. Cuisines
                guard let cuisines = rest["cuisines"] as? String else {
                    print("Could not get cuisines")
                    return
                }
            
                guard let location = rest["location"] else {
                    print("Could not get location")
                    return
                }
                
//               3. address
                guard let address = location["address"]as? String else {
                    print("Adress Unavailable")
                    return
                }
//                4. locality
                guard let locality = location["locality"]as? String else {
                    print("locality Unavailable")
                    return
                }
//                5. latitude
                guard let latitude = location["latitude"]as? String else {
                    print("latitude Unavailable")
                    return
                }
                
//                6. longitude
                guard let longitude = location["longitude"]as? String else {
                    print("longitude Unavailable")
                    return
                }
//                7. name
                guard let name = rest["name"] as? String else {
                    print("Could not find name of restaurant")
                    return
                }
//                8. average cost for two
                guard let averageCostForTwo = rest["average_cost_for_two"] as? Int else {
                    print("Could not find price")
                    return
                }
//                9. currency
                guard let currency = rest["currency"]as? String else {
                    print("Currency unit not found")
                    return
                }
//                10. image
                guard let imageURLString = rest["featured_image"]  as? String else {
                    print("Featured Image not found")
                    return
                }
                
                guard let ratingDetails = rest["user_rating"] else {
                    print("could not find ratings")
                    return
                }
//                11. aggregateRating
                guard let aggregateRating = ratingDetails["aggregate_rating"] as? String else {
                    print("Can't find rating")
                    return
                }
                
//                12. ratingColor
                guard let ratingColor = ratingDetails["rating_color"] as? String else {
                    print("Can't find ratingColor")
                    return
                }
//              13. ratingText
                guard let ratingText = ratingDetails["rating_text"] as? String else {
                    print("Can't find ratingText")
                    return
                }
//                14. votes
                guard let votes = ratingDetails["votes"] as? String else {
                    print("Can't find votes")
                    return
                }
                
                self.restaurants.append(Restaurant(id: resID, name: name, address: address, locality: locality, latitude: latitude, longitude: longitude, cuisines: cuisines, costForTwo: averageCostForTwo, currency: currency, rating: aggregateRating, ratingText: ratingText, ratingColor: ratingColor, votes: votes, imageURLString: imageURLString))
    
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
        }
        task.resume()

    }
    

}

extension ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! JustCell
        let restaurant = restaurants[indexPath.row]
        cell.img.image = nil
        let url = URL(string : restaurant.imageURLString!)
        
        cell.backgroundCardView.backgroundColor = UIColor.white
        cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        cell.backgroundCardView.layer.cornerRadius = 5.0
        cell.layer.masksToBounds = false
        cell.backgroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        cell.backgroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.backgroundCardView.layer.shadowOpacity = 0.8
        
        
        if restaurant.ratingText == "Not rated" {
            cell.rating.text = "New"
        }
        else {
            cell.rating.text = restaurant.rating
        }
        
        cell.rating.backgroundColor = hexStringToUIColor(hex: restaurant.ratingColor)
        cell.rating.layer.cornerRadius = 3.0
        cell.rating.layer.masksToBounds = true
        cell.restaurantName.text = restaurant.name
        cell.restaurantLocality.text = restaurant.address

        cell.img.sd_setImage(with: url, placeholderImage: nil, options: [.continueInBackground,.progressiveDownload])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        DispatchQueue.main.async {
//            cell.alpha = 0
//            UIView.animate(withDuration: 0.5) {
//                cell.alpha = 1.0
//            }
//        }
        let lastRestaurant = restaurants.count - 1
        if indexPath.row == lastRestaurant {
            getListOfRestaurants(start: start, lat: ViewController.locationLatitude, long: ViewController.locationLongitude)
        }
    }
}
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


