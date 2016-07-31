//
//  ViewController.m
//  LilitabSample
//
//  Created by Kevin Snow on 6/8/16.
//  Copyright © 2016 MynaBay Inc. All rights reserved.
//

#import "ViewController.h"
#import <EndoClient/EndoClient.h>
#import <LilitabSDK/LilitabSDK.h>



@interface ViewController ()

@property (nonatomic,weak) IBOutlet UIButton* statusButton;
@property (nonatomic,weak) IBOutlet UIButton* swipeButton;
@property (nonatomic,weak) IBOutlet UIButton* ledButton;

@end



@implementation ViewController

-(IBAction) buttonStatus:(id)sender
{
    EndoLog(@"Requesting status from reader");
    [[LilitabSDK singleton] status:^(BOOL success, NSDictionary* results)
                                    {
                                        EndoLog(@"status = %@",results);
                                    }];
}

-(IBAction) buttonSwipe:(id)sender
{
    [LilitabSDK singleton].enableSwipe = ![LilitabSDK singleton].enableSwipe;
    
    if( [LilitabSDK singleton].enableSwipe )
    {
        EndoLog(@"Enabled swiping");
        [sender setTitle:@"Disable Swipe" forState:UIControlStateNormal];
    }else{
        EndoLog(@"Disabled swiping");
        [sender setTitle:@"Enable Swipe" forState:UIControlStateNormal];
    }
}

-(IBAction) buttonLED:(id)sender
{
    if( [LilitabSDK singleton].ledState == LED_Off )
    {
        [LilitabSDK singleton].ledState = LED_On;
    }else{
        [LilitabSDK singleton].ledState = LED_Off;
    }
}

-(void) accessoryDidConnect:(NSNotification*)notification
{
    EndoLog(@"accessoryDidConnect");
    
    self.statusButton.enabled = YES;
    self.swipeButton.enabled = YES;
    self.ledButton.enabled = YES;
    
    [LilitabSDK singleton].swipeTimeout = 10;
    [LilitabSDK singleton].swipeBlock = ^(NSDictionary* swipeData)
                                        {
                                            EndoLog(@"swipeData = %@",swipeData);
                                            
                                            [self.swipeButton setTitle:@"Enable Swipe" forState:UIControlStateNormal];
                                        };
}

-(void) accessoryDidDisconnect:(NSNotification*)notification
{
    EndoLog(@"accessoryDidDisconnect");
    
    self.statusButton.enabled = NO;
    self.swipeButton.enabled = NO;
    self.ledButton.enabled = NO;
    
    [self.swipeButton setTitle:@"Enable Swipe" forState:UIControlStateNormal];
    
    [LilitabSDK singleton].swipeBlock = NULL;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDidConnect:)
                                                 name:LilitabSDK_DidConnectNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessoryDidDisconnect:)
                                                 name:LilitabSDK_DidDisconnectNotification
                                               object:nil];
    
    [[LilitabSDK singleton] scanForConnectedAccessories];
    
    [LilitabSDK singleton].ledState = LED_Off;
}

@end
