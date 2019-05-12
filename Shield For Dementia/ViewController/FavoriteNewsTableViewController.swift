//
//  FavoriteNewsTableViewController.swift
//  Shield For Dementia Carer
//
//  Created by 彭孝诚 on 2019/5/11.
//  Copyright © 2019 彭孝诚. All rights reserved.
//
import CoreData
import UIKit


class FavoriteNewsTableViewController: UITableViewController {
    var newsList:[NSManagedObject] = [NSManagedObject]()
    var valueToPass:News?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchNewsFromCoreData()
        tableView.reloadData()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return newsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "favNewsCell", for: indexPath) as! NewsTableViewCell
        let newsItem = News(title: newsList[row].value(forKey: "newsTitle") as! String, description: newsList[row].value(forKey: "newsDesc") as! String, pubDate: newsList[row].value(forKey: "newsPubDate") as! String, imageLink: "", link: newsList[row].value(forKey: "newsLink") as! String)
        cell.newsItem = newsItem
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newsToPassCD = newsList[indexPath.row]
        valueToPass = News(title: newsToPassCD.value(forKey: "newsTitle") as! String, description: newsToPassCD.value(forKey: "newsDesc") as! String, pubDate: newsToPassCD.value(forKey: "newsPubDate") as! String, imageLink: "", link: newsToPassCD.value(forKey: "newsLink") as! String)
        performSegue(withIdentifier: "favNewsDetailSegue", sender: self)
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let newsToDelete = newsList[indexPath.row]
            context.delete(newsToDelete)
            
            do{
                try context.save()
                newsList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch{
                print(error)
            }
            
            
        }
    }
    

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "favNewsDetailSegue"{
            let vc = segue.destination as! NewsDetailViewController
            vc.news = valueToPass
        }
    }

    func fetchNewsFromCoreData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsCoreData")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            newsList = result as! [NSManagedObject]
        } catch {
            print("Failed")
        }
    }
}
