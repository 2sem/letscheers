//
//  LCToastTableViewController.swift
//  letscheers
//
//  Created by 영준 이 on 2017. 1. 7..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
//import XMLDictionary

class LCToastTableViewController: UITableViewController, UISearchBarDelegate {
    static let CellID = "LCToastTableViewCell";
    
    private(set) var toasts : [LCToast] = [];
    func updateToasts(){
        var value = LCExcelController.Default.categories.first { (category) -> Bool in
            return category.name == self.category;
            }?.toasts ?? [];
        if self.searchBar.text?.isEmpty == false{
            value = value.filter({ (toast) -> Bool in
                return toast.title.contains(self.searchBar.text ?? "");
            }) ?? [];
        }
        
        self.toasts = value;
    }
    
    var category : String?;
    var modelController : LCModelController{
        get{
            return LCModelController.Default;
        }
    }
    
    var background : UIImage?;
    var backgroundView : UIImageView?;
    
//    var searchBar : UISearchBar!;
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func onRandomButton(_ sender: UIBarButtonItem) {
        var toast = LCExcelController.Default.randomToast(self.category ?? "");
        //self.showAlert(title: toast.title, msg: toast.contents, actions: [UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
        self.popupAndShare(title: toast.title, contents: toast.contents);
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isHidden = false;
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isHidden = true;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard self.background != nil else{
            return;
        }
        
        self.backgroundView = UIImageView(frame: self.tableView.frame);
        self.backgroundView?.contentMode = .scaleAspectFill;
        self.backgroundView?.alpha = 0.3;
        self.backgroundView?.image = self.background;
        self.tableView.addSubview(self.backgroundView!);
        self.tableView.sendSubview(toBack: self.backgroundView!);
        
        
//        var controller = UISearchController();
//        self.searchBar = controller.searchBar;
//        self.tableView.tableHeaderView = self.searchBar;
//        self.navigationController?.navigationBar.isHidden = false;
//        self.toasts = LCExcelController.Default.loadToasts(withCategory: self.category ?? "");
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCheckFav(button : UIButton){
        let cell = button.superview?.superview as! LCToastTableViewCell;
        //        print("check fav cell -> \(cell)");
        var value = !button.isSelected;
        
        var toast = self.modelController.findFavorite(withName: cell.nameLabel.text ?? "").first;
        if cell.favoriteButton.isSelected{
            
            guard toast != nil else{
                return;
            }
            
            self.modelController.removeFavorite(toast: toast!);
        }else{
            guard toast == nil else{
                return;
            }
            
            self.modelController.createFavorite(name: cell.nameLabel.text ?? "", contents: cell.contentLabel.text ?? "");
        }
        
        cell.favoriteButton.isSelected = value;
        self.modelController.saveChanges();
        //        var stock : RSStoredStock?;
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        self.updateToasts();
        return self.toasts.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LCToastTableViewController.CellID, for: indexPath) as? LCToastTableViewCell;

        var toast = self.toasts[indexPath.row];
        cell?.nameLabel.text = toast.title;
        cell?.contentLabel.text = toast.contents;
        cell?.selectedBackgroundView = UIView();
        //cell?.selectedBackgroundView.alpha = 0.5;
        
//        cell.textLabel?.text = toast.title;
        // Configure the cell...
        cell?.favoriteButton.addTarget(self, action: #selector(onCheckFav(button:)), for: .touchUpInside);
        
        var isFav = self.modelController.isExistFavorite(withName: cell?.nameLabel.text ?? "") ? true : false;
        
        var img = cell?.favoriteButton.image(for: .selected)?.withRenderingMode(.alwaysTemplate);
        cell?.favoriteButton.setImage(img, for: .selected);
        
        cell?.favoriteButton.isSelected = isFav;
        print("check cell[\(indexPath.row)] name[\(cell?.nameLabel.text)] button[\(cell?.favoriteButton)] selected[\(isFav)]");
        
        return cell!;
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell : LCToastTableViewCell! = tableView.cellForRow(at: indexPath) as? LCToastTableViewCell;
        
        guard cell != nil else{
            return;
        }
        //return;
        
        var name = cell?.nameLabel?.text ?? "";
        var contents = cell?.contentLabel?.text ?? "";
//        if !contents.isEmpty{
//            contents = "\n- " + contents;
//        }
//        contents = contents + "\n#" + self.displayAppName;
        var msg = "\(name)\(contents)";
        
        self.popupAndShare(title: name, contents: contents);

//        self.share([msg]);
    }
    
    func popupAndShare(title : String, contents: String){
        var contents = contents;
        
//        var msg = "\(title)\(contents)";
        
        self.showAlert(title: title, msg: contents, actions: [UIAlertAction(title: "공유", style: .default, handler: {(act) -> Void in
            if !contents.isEmpty{
                contents = "\n- " + contents;
            }
            
            var tag = "\n#" + self.displayAppName;
            self.share([title + contents + tag]);
        }), UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.backgroundView?.frame.origin.y = self.view.frame.maxY - (self.backgroundView?.frame.height ?? 0);
        self.backgroundView?.frame.origin.y = scrollView.contentOffset.y;
    }
    
    // MARK: UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.tableView.reloadData();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "";
        searchBar.resignFirstResponder();
        self.tableView.reloadData();
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
