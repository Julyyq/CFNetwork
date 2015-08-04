
//
//  ViewController.m
//  CFNetwork
//
//  Created by Allen.Young on 28/7/15.
//  Copyright (c) 2015 Allen.Young. All rights reserved.
//

#import "ViewController.h"

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
void callback(CFReadStreamRef stream, CFStreamEventType event, void *myPtr) {
    if(event == kCFStreamEventHasBytesAvailable) {
        UInt8 buf[1024];
        CFIndex numBytes = CFReadStreamRead(stream, buf, 1024);
        
        CFHTTPMessageRef response = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
        
        CFIndex responseCode = CFHTTPMessageGetResponseStatusCode(response);
        
        if(responseCode == 200) {
            CFHTTPMessageRef response = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, FALSE);
            CFHTTPMessageAppendBytes(response, buf, numBytes);
            
            NSError *error = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithBytes:buf length:numBytes] options:kNilOptions error:&error];
            
            NSLog(@"%@", json);
        }
    }
}
- (IBAction)sendRequest:(id)sender {
    CFStringRef url = CFSTR("http://localhost:3000/test");
    CFURLRef urlRef = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
    
    CFStringRef requestMethod = CFSTR("GET");
    
    CFStringRef headerFieldName = CFSTR("Accept");
    CFStringRef headerFieldValue = CFSTR("application/json");
    
    CFHTTPMessageRef request  = CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, urlRef, kCFHTTPVersion1_1);
    
    CFHTTPMessageSetHeaderFieldValue(request, headerFieldName, headerFieldValue);
    
    CFReadStreamRef stream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, request);
    
    CFStreamClientContext myContext = {0, NULL, NULL, NULL, NULL};
    CFOptionFlags registeredEvents = kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
    
    if(CFReadStreamSetClient(stream, registeredEvents, callback, &myContext)) {
        CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    
    CFReadStreamOpen(stream);
    
    CFRunLoopRun();
}

@end
