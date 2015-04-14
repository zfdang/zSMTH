//
//  AttachSelectorTableViewController.m
//  zSMTH
//
//  Created by Zhengfa DANG on 2015-4-13.
//  Copyright (c) 2015 Zhengfa. All rights reserved.
//

#import "AttachSelectorTableViewController.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsPageViewController.h"
#import "ContentEditViewController.h"

@interface AttachSelectorTableViewController () <CTAssetsPickerControllerDelegate>


@property (nonatomic, strong) NSDateFormatter *dateFormatter;
//@property (nonatomic, strong) UIPopoverController *popover;

@end

@implementation AttachSelectorTableViewController

@synthesize mAssets;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterMediumStyle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)finish:(id)sender {
    if(self.delegate){
        [self.delegate updateAttachments:self.mAssets];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)select:(id)sender {
    if (!self.mAssets)
        self.mAssets = [[NSMutableArray alloc] init];
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allPhotos];  // Only pick photos.
    picker.showsCancelButton    = NO;
    picker.delegate             = self;
    picker.showsNumberOfAssets  = YES;
    picker.selectedAssets       = [NSMutableArray arrayWithArray:self.mAssets];
    
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mAssets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    ALAsset *asset = [self.mAssets objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.dateFormatter stringFromDate:[asset valueForProperty:ALAssetPropertyDate]];
    cell.detailTextLabel.text = [asset valueForProperty:ALAssetPropertyType];
    cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CTAssetsPageViewController *vc = [[CTAssetsPageViewController alloc] initWithAssets:self.mAssets];
    vc.pageIndex = indexPath.row;
    
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Assets Picker Delegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    self.mAssets = [NSMutableArray arrayWithArray:assets];
    [self.tableView reloadData];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    return YES;
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    int maxmiumImages = 1;
    if (picker.selectedAssets.count >= maxmiumImages)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"注意"
                                   message:[NSString stringWithFormat:@"由于API的限制，现阶段只能上载%d个图片",maxmiumImages]
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < maxmiumImages && asset.defaultRepresentation != nil);
}

@end
