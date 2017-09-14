//
//  AppDelegate.m
//  IPAInfo
//
//  Created by Jakey on 15/1/4.
//  Copyright (c) 2015年 www.skyfox.org. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (!flag)
    {
        [self.window makeKeyAndOrderFront:self];
    }
    return YES;
}

- (IBAction)look:(id)sender {
    if ([[[self.originalIpaPath.stringValue pathExtension] lowercaseString] isEqualToString:@"ipa"]) {
        workingPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"org.skyfox.ipainfo"];
        [[NSFileManager defaultManager] removeItemAtPath:workingPath error:nil];

        
        unzipTask = [[NSTask alloc] init];
        [unzipTask setLaunchPath:@"/usr/bin/unzip"];
        [unzipTask setArguments:[NSArray arrayWithObjects:@"-q", self.originalIpaPath.stringValue, @"-d", workingPath, nil]];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkUnzip:) userInfo:nil repeats:TRUE];
        
        [unzipTask launch];
    }

}
- (NSString*)findPlist{
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[workingPath stringByAppendingPathComponent:@"Payload"] error:nil];
    NSString *infoPlistPath = nil;
    
    for (NSString *file in dirContents) {
        if ([[[file pathExtension] lowercaseString] isEqualToString:@"app"]) {
            infoPlistPath = [[[workingPath stringByAppendingPathComponent:@"Payload"]
                              stringByAppendingPathComponent:file]
                             stringByAppendingPathComponent:@"Info.plist"];
            appPath = [[workingPath stringByAppendingPathComponent:@"Payload"] stringByAppendingPathComponent:file];

           
            break;
        }
    }
    return infoPlistPath;
    
}

- (void)checkUnzip:(NSTimer *)timer {
    if ([unzipTask isRunning] == 0) {
        [timer invalidate];
        unzipTask = nil;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[workingPath stringByAppendingPathComponent:@"Payload"]]) {
            NSLog(@"Unzipping done");
            [statusLabel setStringValue:@"Original app extracted"];
            NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[self findPlist]];
            [resultText setString:[plistDic description]];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[appPath stringByAppendingPathComponent:@"embedded.mobileprovision"]]) {
                
                NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:[appPath stringByAppendingPathComponent:@"embedded.mobileprovision"] encoding:NSASCIIStringEncoding error:nil];
                NSArray* embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:
                                                      [NSCharacterSet newlineCharacterSet]];
                
                NSMutableDictionary *dic = (NSMutableDictionary*)[self readPlist:[appPath stringByAppendingPathComponent:@"embedded.mobileprovision"]];
                
                [signText setString:[dic description]];
            }
            
        } else {
           
            [statusLabel setStringValue:@"Ready"];
        }
    }
}
- (NSDictionary*)readPlist:(NSString *)filePath
{
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        NSString *startString = @"<?xml version";
        NSString *endString = @"</plist>";
        
        NSData *rawData = [NSData dataWithContentsOfFile:filePath];
        NSData *startData = [NSData dataWithBytes:[startString UTF8String] length:startString.length];
        NSData *endData = [NSData dataWithBytes:[endString UTF8String] length:endString.length];
        
        NSRange fullRange = {.location = 0, .length = [rawData length]};
        
        NSRange startRange = [rawData rangeOfData:startData options:0 range:fullRange];
        NSRange endRange = [rawData rangeOfData:endData options:0 range:fullRange];
        
        NSRange plistRange = {.location = startRange.location, .length = endRange.location + endRange.length - startRange.location};
        NSData *plistData = [rawData subdataWithRange:plistRange];
        
        id obj = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:NULL error:nil];
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            return obj;
        }
    }
    return nil;
}
@end
