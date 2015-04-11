//
//  ViewController.swift
//  Yahoo Finance iPhone
//
//  Created by adm on 3/29/15.
//  Copyright (c) 2015 inDabusiness. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var strDate: UILabel!
    @IBOutlet weak var strSymbol: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var strResult: UITextView!
    
    var symbol = "AAPL"
    var date = "2015-03-27"
    var result = ""
    
    func queryYahoo(symbol:String, date:String) -> NSData! {
        let query = "http://query.yahooapis.com/v1/public/yql?q=select * from yahoo.finance.historicaldata where symbol = \"\(symbol)\" and startDate = \"\(date)\" and endDate = \"\(date))\"&format=json&diagnostics=false&env=store://datatables.org/alltableswithkeys&callback=".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if let queryUrl = NSURL(string: query) {
            if let urlData = NSData(contentsOfURL: queryUrl) {
                return urlData
            }
        }
        return nil
    }
    
    func parseQuery(data:NSData) -> (date:String, symbol:String, open:String, close:String, adj_close:String, volume:String, high:String, low:String ) {
        
        let quote     = JSON(data: data)["query"]["results"]["quote"]
        println(quote)
        let date      = quote["Date"]
        let symbol    = quote["Symbol"]
        let open      = quote["Open"]
        let close     = quote["Close"]
        let adj_close = quote["Adj_Close"]
        let volume    = quote["Volume"]
        let high      = quote["High"]
        let low       = quote["Low"]
        if date.description == "null" {
            return ("closed","closed","closed","closed","closed","closed","closed","closed")
            
        }
        return (date.description,symbol.description,open.description,close.description,adj_close.description,volume.description,high.description,low.description)
    }
    func reloadStockData() {
        if let data = queryYahoo(symbol, date: date) {
            let quote = parseQuery(data)
            result += ("Date: " + quote.date) + "\n"
            result += ("Symbol: " + quote.symbol) + "\n"
            result += ("Open: $" + quote.open) + "\n"
            result += ("Close: $" + quote.close) + "\n"
            result += ("Adj Close: $" + quote.adj_close) + "\n"
            result += ("Volume: " + quote.volume) + "\n"
            result += ("High: $" + quote.high) + "\n"
            result += ("Low: $" + quote.low) + "\n"
            strResult.text = result
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        strSymbol.text = symbol

        let dow = NSDate().dow

        if dow > 1 && dow < 7 {
           datePicker.date = NSDate()
            date = NSDate().string
        } else {
            if dow == 1 {
                datePicker.date = NSDate().x(days: -2)
                date = NSDate().x(days: -2).string
            } else {
                datePicker.date = NSDate().x(days: -1)
                date = NSDate().x(days: -1).string
           }
        }
        strDate.text = datePicker.date.dayOfWeek
        reloadStockData()
        
    }
    
    
    // Do any additional setup after loading the view, typically from a nib.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func symbolChanged(sender: UITextField) {
        
        symbol = sender.text
        result = ""
        reloadStockData()
        
        
    }
    @IBAction func dateChanged(sender: UIDatePicker) {
        if sender.date.compare(NSDate()) == NSComparisonResult.OrderedDescending {
         sender.date = NSDate()
        } else {
            
            if sender.date.lastBusinessDay.compare(sender.date) == NSComparisonResult.OrderedAscending {
                sender.date = sender.date.lastBusinessDay
            }
            
            let senderDow = sender.date.dow
            date = sender.date.string
            strDate.text = sender.date.dayOfWeek
            result = ""
            reloadStockData()
        }
        
    }

}

extension NSDate {
    var dow:Int {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.component(NSCalendarUnit.CalendarUnitWeekday, fromDate: self)
    }
    var lastBusinessDay: NSDate {
        if dow > 1 && dow < 7 {
            return self
        } else {
            if dow == 1 {
                return x(days: -2)
            } else {
                return x(days: -1)
            }
        }
    }
    var string: String {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.stringFromDate(self)
    }
    var dayOfWeek: String {
        let df = NSDateFormatter()
        df.dateFormat = "EEEE"
        return df.stringFromDate(self)
    }
    func x(#days:Int) -> NSDate {
        return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.dateByAddingUnit(.CalendarUnitDay, value: days, toDate: self, options: nil)!
    }

}

