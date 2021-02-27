//
//  LCFavoriteTableViewController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import CoreData

class LCFavoriteTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    static let CellID = LCToastTableViewController.CellID;
    //var favorites : [FavoriteToast] = [];
    lazy var favoriteController : LCFavoriteModelViewController! = LCFavoriteModelViewController(self);
    var editButton : UIBarButtonItem!;
    var doneButton : UIBarButtonItem!;
    var cancelButton : UIBarButtonItem!;
    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh();
    }
    
    var dataSource: UITableViewDataSource?;
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = nil;
        self.dataSource = self.favoriteController.fetchController.lx.bindTableView(to: self.tableView, cellIdentifier: type(of: self).CellID, entityType: FavoriteToast.self, cellType: LCToastTableViewCell.self) { (index, fav, cell) in
            cell.nameLabel.text = fav.name;
            cell.contentLabel.text = LCExcelController.shared.findToast(fav.name!)?.contents;
            cell.selectedBackgroundView = UIView();
        }
        print("created tableView source[\(self.dataSource?.description ?? "")]");
        self.setEditButton();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh(){
        //self.favorites = LCModelController.shared.loadFavorites();
        //        self.tableView.reloadData();
        self.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic);
    }

    internal func setEditButton(){
        if self.editButton == nil{
            //            self.editButton = UIBarButtonItem.init(barButtonSystemItem: .edit, target: self, action: #selector(onBeginEdit(button:)));
            self.editButton = UIBarButtonItem.init(title: "수정", style: .plain, target: self, action: #selector(onBeginEdit(button:)));
        }
        self.navigationItem.rightBarButtonItem = self.editButton;
    }
    
    @IBAction func onBeginEdit(button : UIBarButtonItem){
        self.tableView.setEditing(true, animated: true);
        if self.doneButton == nil{
            //            self.doneButton = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(onEndEdit(button:)));
            self.doneButton = UIBarButtonItem.init(title: "완료", style: .plain, target: self, action: #selector(onEndEdit(button:)));
        }
        self.navigationItem.rightBarButtonItem = self.doneButton;
        
        if self.cancelButton == nil{
            //            self.cancelButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelEdit(button:)));
            self.cancelButton = UIBarButtonItem.init(title: "취소", style: .plain, target: self, action: #selector(onCancelEdit(button:)));
        }
        self.navigationItem.leftBarButtonItem = self.cancelButton;
    }
    
    @IBAction func onEndEdit(button : UIBarButtonItem){
        self.setEditButton();
        self.tableView.setEditing(false, animated: true);
        self.navigationItem.leftBarButtonItem = nil;
        LCModelController.shared.saveChanges();
    }
    
    @IBAction func onCancelEdit(button : UIBarButtonItem){
        var needToReload = !LCModelController.shared.isSaved;
        LCModelController.shared.reset();
        defer{
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = self.editButton;
            self.tableView.setEditing(false, animated: true);
        }
        guard needToReload else{
            return;
        }
        self.refresh();
        //        DispatchQueue.main.async {
        
        //        }
    }
    
    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.favoriteController.fetchedGroupCount;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.favoriteController.fetchedCount(forGroup: section);
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LCToastTableViewController.CellID, for: indexPath) as? LCToastTableViewCell;
        
        guard let toast = self.favoriteController.fetch(forSection: indexPath.section, forIndex: indexPath.row) else{
            preconditionFailure("Can not fetch favorite information. indexPath[\(indexPath)]");
        }
        
        //var toast = self.favorites[indexPath.row];
        cell?.nameLabel.text = toast.name;
        cell?.contentLabel.text = LCExcelController.shared.findToast(toast.name!)?.contents;
        cell?.selectedBackgroundView = UIView();
//        cell?.contentLabel.text = toast.contents;
        //        cell.textLabel?.text = toast.title;
        // Configure the cell...
//        cell?.favoriteButton.addTarget(self, action: #selector(onCheckFav(button:)), for: .touchUpInside);
        
//        var isFav = self.modelController.isExistFavorite(withName: cell?.nameLabel.text ?? "") ? true : false;
//        
//        var img = cell?.favoriteButton.image(for: .selected)?.withRenderingMode(.alwaysTemplate);
//        cell?.favoriteButton.setImage(img, for: .selected);
//        
//        cell?.favoriteButton.isSelected = isFav;
//        print("check cell[\(indexPath.row)] name[\(cell?.nameLabel.text)] button[\(cell?.favoriteButton)] selected[\(isFav)]");
        
        return cell!;
    }*/

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //            var cell = self.tableView.cellForRow(at: indexPath) as? RSSearchCell;
            //            var title = cell?.titleLabel.text;
            //            if title != nil{
            //
            //            }
            //var toast = self.favorites[indexPath.row];
            //self.favorites.remove(at: indexPath.row);
            //LCModelController.shared.removeFavorite(toast: toast);
            //tableView.deleteRows(at: [indexPath], with: .fade);
            guard let toast = self.favoriteController.fetch(forSection: indexPath.section, forIndex: indexPath.row) else{
                return;
            }
            
            self.favoriteController.removeFavorite(toast: toast);
            LCModelController.shared.saveChanges();
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates();
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates();
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
            case .insert:
                print("Inserting row is detected. index[\(newIndexPath!.description)]");
                self.tableView.insertRows(at: [newIndexPath!], with: .fade);
                break;
            case .delete:
                print("Deleting row is detected. index[\(indexPath!.description)]");
                self.tableView.deleteRows(at: [indexPath!], with: .fade);
                break;
            default:
                break;
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        AppDelegate.sharedGADManager?.show(unit: .full) { [weak self](unit, ad, result) in
            self?.performSegue(withIdentifier: identifier, sender: sender);
        }
        
        return false;
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
