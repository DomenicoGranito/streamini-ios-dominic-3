//
//  VidQualityvc.swift
//  Music Player
//
//  Created by Sem on 7/3/15.
//  Copyright (c) 2015 Sem. All rights reserved.
//

import UIKit
import CoreData

class Settings: UITableViewController {
    
    var context : NSManagedObjectContext!
    var settings : NSManagedObject!
    
    func selectRow(path : NSIndexPath){
        tableView.selectRowAtIndexPath(path, animated: false, scrollPosition: UITableViewScrollPosition.None)
        tableView.cellForRowAtIndexPath(path)?.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    func deselectRow(path : NSIndexPath){
        tableView.deselectRowAtIndexPath(path, animated: false)
        tableView.cellForRowAtIndexPath(path)?.accessoryType = UITableViewCellAccessoryType.None
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        
        let appDel = UIApplication.sharedApplication().delegate as? AppDelegate
        context = appDel!.managedObjectContext
        
        //retrieve settings, or initialize default settings if unset
        settings = MiscFuncs.getSettings()
        let qualRow = NSIndexPath(forRow: settings.valueForKey("quality") as! Int, inSection: 0)
        deselectRow(qualRow)
        selectRow(qualRow)
        
        let cacheRow = NSIndexPath(forRow: settings.valueForKey("cache") as! Int, inSection: 1)
        deselectRow(cacheRow)
        selectRow(cacheRow)
        
        //set background
        tableView.backgroundColor = UIColor.clearColor()
        let imgView = UIImageView(image: UIImage(named: "pastel.jpg"))
        imgView.frame = tableView.frame
        tableView.backgroundView = imgView        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor.clearColor()
        header.backgroundView?.backgroundColor = UIColor.clearColor()
    }
    
    //deselect previously selected rows that are in same section
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let selectedRows = tableView.indexPathsForSelectedRows as [NSIndexPath]?{
            for selectedIndexPath : NSIndexPath in selectedRows{
                if selectedIndexPath.section == indexPath.section{
                    tableView.deselectRowAtIndexPath(selectedIndexPath, animated: false)
                    tableView.cellForRowAtIndexPath(selectedIndexPath)?.accessoryType = UITableViewCellAccessoryType.None
                }
            }
        }
        return indexPath
    }
    
    //0 is videoQual, 1 is cache Video
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        switch indexPath.section {
        case 0: //Video Quality
            settings.setValue(indexPath.row, forKey: "quality")
        case 1://Video Caching
            settings.setValue(indexPath.row, forKey: "cache")
        default:
            break
        }
        
        do {
            try context.save()
        } catch _ {
        }
    }
    
   //user cannot deselect cells manually
   override func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
}
