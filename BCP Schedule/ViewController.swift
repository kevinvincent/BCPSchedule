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
    
    //class list
    var myList:[String] = ["Loading..."];
    
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup Pull to Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        //Animate in labels
        animateIn()
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
        //Tell the table to have the correct number of rows ready
        cell.textLabel.text = myList[indexPath.row]
        return cell;
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
    }
    
    func animateIn() {
        //get frame
        var weekdayFrame = self.weekDayLabel.frame;
        
        //save the original x for later
        var weekdayOriginalX = weekdayFrame.origin.x;
        
        //move it to the right 10
        weekdayFrame.origin.x += 20;
        weekDayLabel.frame = weekdayFrame
        
        //make it transparent
        weekDayLabel.alpha = 0.0;
        
        //Animate it it back
        UIView.animateWithDuration(1.00,
            
            animations: {
                self.weekDayLabel.alpha = 1.0;
                weekdayFrame.origin.x = weekdayOriginalX;
                self.weekDayLabel.frame = weekdayFrame;
            },
            completion: {
                (value: Bool) in
                println(">>> Weekday Animation Complete")
            }
        )
        
        //Rinse and repeat with Date Label
        var dateFrame = dateLabel.frame;
        
        var dateOriginalX = dateFrame.origin.x;
        
        dateFrame.origin.y += 10;
        dateLabel.frame = dateFrame
        
        dateLabel.alpha = 0.0;
        
        UIView.animateWithDuration(1.00,
            
            animations: {
                self.dateLabel.alpha = 1.0;
                dateFrame.origin.y = dateOriginalX;
                self.dateLabel.frame = dateFrame;
            },
            completion: {
                (value: Bool) in
                println(">>> Date Animation Complete")
            }
        )
    }
    
    func updateDay(){
        //All of this code just gets the date
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitWeekday | .CalendarUnitDay | .CalendarUnitMonth, fromDate: date);
        let weekdayIndex = components.weekday
        var listOfDays:[String] = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        
        //Display the day of the week
        weekDayLabel.text = listOfDays[weekdayIndex-1];
        
        //Dispay the date nicely above it
        dateLabel.text = "\(components.month) / \(components.day)"
    }
    
    func getData(){
        //Where we get the schedule from
        let url = NSURL(string: "http://desolate-beach-1823.herokuapp.com/")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            //If there is an error, make a popup
            if (error != nil){
                var alert = UIAlertController(title: "Error", message: "Contact A Developer", preferredStyle: UIAlertControllerStyle.Alert)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
            //Get data from server as string
            var data:String = NSString(data: data, encoding: NSUTF8StringEncoding)!
            
            //Make that data an array
            var dataAsArray:[String] = data.componentsSeparatedByString("-");
            
            //Get class list from stored data
            var cdata: String = String(NSUserDefaults.standardUserDefaults().objectForKey("classlist")! as String)
            
            //Parse the classlist
            var classArray = self.JSONParseArray(cdata)
            
            //Basically just references both arrays and overrites one of them to what the displayed table should say
            for (var i = 0; i < dataAsArray.count; i++) {
                if (dataAsArray[i] != "H" && dataAsArray[i] != "A" && dataAsArray[i] != "E"){
                    if (classArray[dataAsArray[i].toInt()! - 1] as NSString != ""){
                        dataAsArray[i] = "\(classArray[dataAsArray[i].toInt()! - 1])"
                    } else {
                        dataAsArray[i] = "Period \(dataAsArray[i])"
                    }
                }
                if (dataAsArray[i] == "H"){
                    dataAsArray[i] = "Homeroom"
                }
                
            }
            
            //Set list to the one we were messing with in this part of the code
            self.myList = dataAsArray;
            
            //Tell the table to refresh with the new data we got
            self.tableView.reloadData();
            
            //Set title
            self.Title.topItem?.title = data;
            
            self.refreshControl.endRefreshing()
        }
    }
    
    //Got from internetz
    func JSONParseArray(jsonString: String) -> [AnyObject] {
        if let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            if let array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: nil)  as? [AnyObject] {
                return array
            }
        }
        return [AnyObject]()
    }
    
}

