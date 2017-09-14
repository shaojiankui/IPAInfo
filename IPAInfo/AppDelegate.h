//
//  AppDelegate.h
//  IPAInfo
//
//  Created by Jakey on 15/1/4.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TextFieldDrag.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSTask *unzipTask;
    NSString *workingPath;
    NSString *appPath;
   
    __unsafe_unretained IBOutlet NSTextView *signText;
    __unsafe_unretained IBOutlet NSTextView *resultText;
    __weak IBOutlet NSTextField *statusLabel;
}
@property (weak) IBOutlet TextFieldDrag *originalIpaPath;

- (IBAction)look:(id)sender;

@end

