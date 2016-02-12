//
//  ViewController.swift
//  SummerProject
//
//  Created by Michael Vienneau on 6/24/15.
//  Copyright (c) 2015 Michael Vienneau. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation




class ViewController: UIViewController, CLLocationManagerDelegate,
    UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    @IBAction func uploadPressed(sender: AnyObject) {
        imageUploadRequest()
        
    }
    
    @IBAction func takePhotoPressed(sender: AnyObject) {
        var myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myPickerController, animated: true, completion: nil)
        
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
        
    {
        myImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ask for authorization from user
        self.locationManager.requestAlwaysAuthorization()
        
        //Foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }else{
            println("Location Services not Enabled")
        }
        
        
        
    }
    
    func imageUploadRequest()
    {
        //Server side script ready
        let myUrl = NSURL(string: "http://localhost/MAMP/test.php/");
        
        //latitude,longitude = getIntLatLong()
        
        
        //auto unwrap the URL, use method POST
        let request = NSMutableURLRequest(URL:myUrl!);
        request.HTTPMethod = "POST";
        
        //Get first and last name params from PHP login
        
        let param = [
            "firstName"  : "Michael",
            "lastName"    : "Vienneau",
            //"longitude"    : longitude,
            //"latitude"      : latitude
        ]
        let name = "Michael-Vienneau-Photo"
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(myImageView.image, 1)
        
        if(imageData==nil)  { return; }
        
        request.HTTPBody = createBodyWithParameters(name, parameters: param as? [String : String], filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        
        
        
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            // You can print out response object
            println("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("****** response data = \(responseString!)")
            
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers, error: &err) as? NSDictionary
            
            
            
            dispatch_async(dispatch_get_main_queue(),{
                self.myImageView.image = nil;
            });
            
            /*
            if let parseJSON = json {
            var firstNameValue = parseJSON["firstName"] as? String
            println("firstNameValue: \(firstNameValue)")
            }
            */
            
        }
        
        task.resume()
        
    }
    
    
    func createBodyWithParameters(photoName: String, parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        var body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        //Needed for HTTPRequest to be valid
        var filename = photoName + ".jpg"
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        var initialLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        
        centerMapOnLocation(initialLocation)
        
    }
    
    func getLatitude(manager: CLLocationManager!) -> CLLocationDegrees{
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        return locValue.latitude
    }
    func getLongitude(manager: CLLocationManager!) -> CLLocationDegrees{
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        return locValue.longitude
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        
        //println("locations = \(location.coordinate.latitude) \(location.coordinate.longitude)")
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}


