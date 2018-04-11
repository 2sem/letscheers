//
//  LCFavoriteTableViewController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

class LCFavoriteTableViewController: UITableViewController {

    var favorites : [FavoriteToast] = [];
    var editButton : UIBarButtonItem!;
    var doneButton : UIBarButtonItem!;
    var cancelButton : UIBarButtonItem!;
    
    override func viewDidAppear(_ animated: Bool) {
        self.refresh();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.favorites = LCModelController.Default.loadFavorites();
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.setEditButton();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refresh(){
        self.favorites = LCModelController.Default.loadFavorites();
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
        LCModelController.Default.saveChanges();
    }
    
    @IBAction func onCancelEdit(button : UIBarButtonItem){
        var needToReload = !LCModelController.Default.isSaved;
        LCModelController.Default.reset();
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LCToastTableViewController.CellID, for: indexPath) as? LCToastTableViewCell;
        
        var toast = self.favorites[indexPath.row];
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
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //            var cell = self.tableView.cellForRow(at: indexPath) as? RSSearchCell;
            //            var title = cell?.titleLabel.text;
            //            if title != nil{
            //
            //            }
            var toast = self.favorites[indexPath.row];
            self.favorites.remove(at: indexPath.row);
            LCModelController.Default.removeFavorite(toast: toast);
            tableView.deleteRows(at: [indexPath], with: .fade);
            if !self.tableView.isEditing{
                LCModelController.Default.saveChanges();
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
