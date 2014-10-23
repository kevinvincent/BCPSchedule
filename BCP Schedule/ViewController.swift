//
//  ViewController.swift
//  BCP Schedule
//
//  Created by Kevin Vincent on 10/21/14.
//  Copyright (c) 2014 bcp. All rights reserved.
//


import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var weekDayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var Title: UINavigationBar!
    
    var myList:[String] = ["Loading..."];
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        println(NSUserDefaults.standardUserDefaults().objectForKey("classlist"))
        //Uncomment next line to clear user data
        //NSUserDefaults.standardUserDefaults().setObject("[]", forKey: "classlist")
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("classlist") == nil) {
            NSUserDefaults.standardUserDefaults().setObject("[\"\", \"\", \"\", \"\", \"\", \"\", \"\"]", forKey: "classlist")
        }

        getData();
        updateDay();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender:AnyObject)
    {
        getData();
        updateDay();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell();
        cell.textLabel.text = myList[indexPath.row]
        return cell;
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    func updateDay(){
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitWeekday | .CalendarUnitDay | .CalendarUnitMonth, fromDate: date);
        let weekdayIndex = components.weekday
        var listOfDays:[String] = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        weekDayLabel.text = listOfDays[weekdayIndex-1];
        dateLabel.text = "\(components.month) / \(components.day)"
    }
    
    func getData(){
        let url = NSURL(string: "http://desolate-beach-1823.herokuapp.com/")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            if (error != nil){
                var alert:UIAlertView = UIAlertView(title: "Error", message: "Contact a developer", delegate: nil, cancelButtonTitle: "Okay", otherButtonTitles:"")
            }
            var data:String = NSString(data: data, encoding: NSUTF8StringEncoding)!
            
            var dataAsArray:[String] = data.componentsSeparatedByString("-");
            
            
            
            var cdata: String = String(NSUserDefaults.standardUserDefaults().objectForKey("classlist")! as String)
            var classArray = self.JSONParseArray(cdata)
            for (var i = 0; i < dataAsArray.count; i++) {
                //"\(dataAsArray[i]) - \(classArray[dataAsArray[i].toInt()! - 1])"
                if (dataAsArray[i] != "H" && dataAsArray[i] != "A" && dataAsArray[i] != "E"){
                    dataAsArray[i] = "\(classArray[dataAsArray[i].toInt()! - 1])"
                }
                if (dataAsArray[i] == "H"){
                    dataAsArray[i] = "Homeroom"
                }
                
            }
            
            self.myList = dataAsArray;
            self.tableView.reloadData();
            self.Title.topItem?.title = data;
            
            self.refreshControl.endRefreshing()
        }
    }
    
    func JSONParseArray(jsonString: String) -> [AnyObject] {
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
                return array
            }
        }
        return [AnyObject]()
    }
    
}

