//
//  CMFlipsideViewController.h
//  iOS Demo
//
//  Copyright (c) 2011 CloudMine, LLC. All rights reserved.
//  See LICENSE file included with SDK for details.
//

#import <UIKit/UIKit.h>

@class CMFlipsideViewController;

@protocol CMFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(CMFlipsideViewController *)controller;
@end

@interface CMFlipsideViewController : UIViewController

@property (weak, nonatomic) IBOutlet id <CMFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
