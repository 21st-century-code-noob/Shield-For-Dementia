//
//  NewsTableViewController.swift
//  Shield For Dementia Carer
//
//  Created by 彭孝诚 on 2019/5/9.
//  Copyright © 2019 彭孝诚. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class NewsTableViewController: UITableViewController {
    var news:[NSManagedObject] = [NSManagedObject]()
    private var newsItems:[News] = [News]()
    var valueToPass:News?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNews()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(false, animated: true)
        var items = [UIBarButtonItem]()
        items.append( UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(favoriteButtonPressed)))
        self.toolbarItems = items
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @objc func favoriteButtonPressed(){
        self.performSegue(withIdentifier: "favoriteNewsSegue", sender: self)
    }
    
    private func fetchNews(){
        let parser = NewsParser()
        parser.parseFeed(url: "https://www.sciencedaily.com/rss/mind_brain/dementia.xml") { (newsItems) in
            self.newsItems = newsItems
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return newsItems.count
        }
        else {return 1}
    }
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
            let item = newsItems[indexPath.row]
            cell.newsItem = item
            let url = URL(string: item.imageLink)
            cell.newsImageLabel.kf.setImage(with:url)

            //       if item.imageLink != ""{
            //          fetchImage(url: item.imageLink, row: indexPath)
            //      }
        
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsSourceCell", for: indexPath) as! NewsSourceTableViewCell
            cell.newsSourceLabel.text = "News Source: Science Daily"
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        valueToPass = newsItems[indexPath.row]
        performSegue(withIdentifier: "newsDetailSegue", sender: self)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newsDetailSegue"{
            let vc = segue.destination as! NewsDetailViewController
            vc.news = valueToPass
        }
    }
    
   
}
