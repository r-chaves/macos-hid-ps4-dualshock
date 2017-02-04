//
//  ViewController.m
//  ps4-dualshock
//
//  Created by Ryan Chaves on 2/4/17.
//  Copyright © 2017 Ryan Chaves. All rights reserved.
//

#import "ViewController.h"
#import <IOKit/hid/IOHIDManager.h>

@interface ViewController()
{
}
@end

static void handle_device_match
(
    void *          inContext,       // context from IOHIDManagerRegisterDeviceMatchingCallback
    IOReturn        inResult,        // the result of the matching operation
    void *          inSender,        // the IOHIDManagerRef for the new device
    IOHIDDeviceRef  inIOHIDDeviceRef // the new HID device
);

static void handle_device_removal
(
    void *          inContext,       // context from IOHIDManagerRegisterDeviceMatchingCallback
    IOReturn        inResult,        // the result of the removing operation
    void *          inSender,        // the IOHIDManagerRef for the device being removed
    IOHIDDeviceRef  inIOHIDDeviceRef // the removed HID device
);

@implementation ViewController
{
    CFAllocatorRef alloc_ref;
    IOHIDManagerRef hid_manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    hid_manager = IOHIDManagerCreate(alloc_ref, kIOHIDOptionsTypeNone);
    
    IOHIDManagerRegisterDeviceMatchingCallback(
        hid_manager, handle_device_match, nil);
    IOHIDManagerRegisterDeviceRemovalCallback(
        hid_manager, handle_device_removal, nil);
    IOHIDManagerSetDeviceMatching(hid_manager, nil);
    IOHIDManagerScheduleWithRunLoop(
        hid_manager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDManagerOpen(hid_manager, kIOHIDOptionsTypeNone);
}


- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

static void handle_device_match
(
    void *          inContext,       // context from IOHIDManagerRegisterDeviceMatchingCallback
    IOReturn        inResult,        // the result of the matching operation
    void *          inSender,        // the IOHIDManagerRef for the new device
    IOHIDDeviceRef  inIOHIDDeviceRef // the new HID device
)
{
    printf("%s(context: %p, result: %i, sender: %p, device: %p).\n",
           __PRETTY_FUNCTION__, inContext, inResult, inSender, inIOHIDDeviceRef);
}

static void handle_device_removal
(
    void *          inContext,       // context from IOHIDManagerRegisterDeviceMatchingCallback
    IOReturn        inResult,        // the result of the removing operation
    void *          inSender,        // the IOHIDManagerRef for the device being removed
    IOHIDDeviceRef  inIOHIDDeviceRef // the removed HID device
)
{
    printf("%s(context: %p, result: %i, sender: %p, device: %p).\n",
           __PRETTY_FUNCTION__, inContext, inResult, inSender, inIOHIDDeviceRef);
}

@end
