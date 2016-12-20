//
//  ViewController.m
//  demo
//
//  Created by MrSong on 2016/12/20.
//  Copyright © 2016年 MrSong. All rights reserved.
//

#import "ViewController.h"
#import "MSActionSheet.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)showUIActionSheet:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"这是一个非常长的 title。这是一个非常长的 title。这是一个非常长的 title。这是一个非常长的 title。这是一个非常长的 title。"
                            delegate:nil
                            cancelButtonTitle:@"取消"
                            destructiveButtonTitle:@"destructiveButton"
                            otherButtonTitles:@"其他1", @"其他2", nil];
    [sheet showInView:self.view];
}

- (IBAction)showUIAlertController:(id)sender
{
    UIAlertController *ac = [UIAlertController
                             alertControllerWithTitle:@"这是一个非常长的 title。这是一个非常长的 title。这是一个非常长的 title。这是一个非常长的 title。这是一个非常长的 title。"
                             message:@"message1。message2。message3。message4。message5。message6。message7。message8。message9。message10。"
                             preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"destructiveButton" style:UIAlertActionStyleDestructive handler:nil];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"其他1" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"其他2" style:UIAlertActionStyleDefault handler:nil];

    [ac addAction:action1];
    [ac addAction:action2];
    [ac addAction:action3];
    [ac addAction:action4];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (IBAction)showMSActionSheet:(id)sender
{
    MSActionSheet *ac = [MSActionSheet
                         actionSheetWithTitle:@"这是一个非常长的 title。这是一个非常长的 title。这是一个非常长的 title。这是一个非常长的 title。这是一个非常长的 title。"
                         message:@"message1。message2。message3。message4。message5。message6。message7。message8。message9。message10。"
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@[@"destructiveButton", @"其他1", @"其他2"]
                         destructiveButtonIndex:0 clickButtonHandle:^(MSActionSheet *ms_actionSheet, NSUInteger clickButtonAtIndex) {
                             if (clickButtonAtIndex == ms_actionSheet.cancelButtonIndex) {
                                 NSLog(@"index:%lu，取消", clickButtonAtIndex);
                             }
                             else if (clickButtonAtIndex == ms_actionSheet.destructiveButtonIndex) {
                                 NSLog(@"index:%lu，destructiveButton", clickButtonAtIndex);
                             }
                             else {
                                 NSLog(@"index:%lu", clickButtonAtIndex);
                             }
                         }];
    [ac showInWindow];
}


@end
