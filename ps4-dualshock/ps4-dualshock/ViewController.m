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
@property NSMutableArray *ds4_list;
@property int num_inputs;
@property int num_reports;
@end

static void handle_device_match
(
    void *          inContext,          // context from IOHIDManagerRegisterDeviceMatchingCallback
    IOReturn        inResult,           // the result of the matching operation
    void *          inSender,           // the IOHIDManagerRef for the new device
    IOHIDDeviceRef  inIOHIDDeviceRef    // the new HID device
);

static void handle_device_removal
(
    void *          inContext,          // context from IOHIDManagerRegisterDeviceMatchingCallback
    IOReturn        inResult,           // the result of the removing operation
    void *          inSender,           // the IOHIDManagerRef for the device being removed
    IOHIDDeviceRef  inIOHIDDeviceRef    // the removed HID device
);

static void handle_device_input
(
    void *          inContext,          // context from IOHIDDeviceRegisterInputValueCallback
    IOReturn        inResult,           // completion result for the input value operation
    void *          inSender,           // IOHIDDeviceRef of the device this element is from
    IOHIDValueRef   inValue             // the new element value
);

static void handle_device_report
(
    void * _Nullable    context,
    IOReturn            result,
    void * _Nullable    sender,
    IOHIDReportType     type,
    uint32_t            reportID,
    uint8_t *           report,
    CFIndex             reportLength
);

@implementation ViewController
{
    IOHIDManagerRef hid_manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.ds4_list = [[NSMutableArray alloc] initWithCapacity:0];
    self.num_inputs = 0;
    self.num_reports = 0;
    
    hid_manager =
        IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    
    NSArray *matchingTypes =
    @[
        @{
            @ kIOHIDDeviceUsagePageKey : @(kHIDPage_GenericDesktop),
            @ kIOHIDDeviceUsageKey     : @(kHIDUsage_GD_Joystick)
        },
        @{
            @ kIOHIDDeviceUsagePageKey : @(kHIDPage_GenericDesktop),
            @ kIOHIDDeviceUsageKey     : @(kHIDUsage_GD_GamePad)
        }
    ];
    
    IOHIDManagerRegisterDeviceMatchingCallback(
        hid_manager, handle_device_match, (__bridge void * _Nullable)(self));
    IOHIDManagerRegisterDeviceRemovalCallback(
        hid_manager, handle_device_removal, (__bridge void * _Nullable)(self));
    IOHIDManagerSetDeviceMatchingMultiple(
        hid_manager, (__bridge CFArrayRef)matchingTypes);
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
    void *          inContext,
    IOReturn        inResult,
    void *          inSender,
    IOHIDDeviceRef  inIOHIDDeviceRef
)
{
    static uint8_t report[64];
    printf("%s(context: %p, result: %i, sender: %p, device: %p).\n",
        __PRETTY_FUNCTION__, inContext, inResult, inSender, inIOHIDDeviceRef);
    ViewController *self = (__bridge ViewController *)inContext;
    [self.ds4_list addObject:(__bridge id _Nonnull)(inIOHIDDeviceRef)];
    IOHIDDeviceRegisterInputValueCallback(
        inIOHIDDeviceRef, handle_device_input, inContext);
    IOHIDDeviceRegisterInputReportCallback(inIOHIDDeviceRef, report, 64, handle_device_report, inContext);
}

static void handle_device_removal
(
    void *          inContext,
    IOReturn        inResult,
    void *          inSender,
    IOHIDDeviceRef  inIOHIDDeviceRef
)
{
    printf("%s(context: %p, result: %i, sender: %p, device: %p).\n",
        __PRETTY_FUNCTION__, inContext, inResult, inSender, inIOHIDDeviceRef);
    ViewController *self = (__bridge ViewController *)inContext;
    [self.ds4_list removeObject:(__bridge id _Nonnull)(inIOHIDDeviceRef)];
    IOHIDDeviceRegisterInputValueCallback(inIOHIDDeviceRef, NULL, inContext);
}

static void handle_device_input
(
    void *          inContext,
    IOReturn        inResult,
    void *          inSender,
    IOHIDValueRef   inValue
)
{
    static const char *input_types[] =
    {
        "misc",
        "button",
        "axis",
        "scancodes",
    };
    
//    printf("%s(context: %p, result: %i, sender: %p, value: %p).\n",
//        __PRETTY_FUNCTION__, inContext, inResult, inSender, inValue);
    ViewController *self = (__bridge ViewController *)inContext;
    ++self.num_inputs;

    const uint64_t timestamp = IOHIDValueGetTimeStamp(inValue);
    const CFIndex length = IOHIDValueGetLength(inValue);
    const uint8_t *byte_ptr = IOHIDValueGetBytePtr(inValue);
    const CFIndex value = IOHIDValueGetIntegerValue(inValue);
    const double_t scaled_value = IOHIDValueGetScaledValue(inValue, kIOHIDValueScaleTypePhysical);

    printf("Value:: timestamp:%lli, length:%li, value:%li\n", timestamp, length, value);
    
    const IOHIDElementRef elem = IOHIDValueGetElement(inValue);
    const IOHIDElementCookie cookie = IOHIDElementGetCookie(elem);
    const IOHIDElementType type = IOHIDElementGetType(elem);
    const IOHIDElementCollectionType collection_type = IOHIDElementGetCollectionType(elem);
    const uint32_t usage_page = IOHIDElementGetUsagePage(elem);
    const uint32_t usage = IOHIDElementGetUsage(elem);
    const Boolean is_virtual = IOHIDElementIsVirtual(elem);
    const Boolean is_relative = IOHIDElementIsRelative(elem);
    const Boolean is_wrapping = IOHIDElementIsWrapping(elem);
    const Boolean is_array = IOHIDElementIsArray(elem);
    const Boolean is_nonlinear = IOHIDElementIsNonLinear(elem);
    const Boolean has_preferred_state = IOHIDElementHasPreferredState(elem);
    const Boolean has_null_state = IOHIDElementHasNullState(elem);
    const CFStringRef name = IOHIDElementGetName(elem);
    const uint32_t report_id = IOHIDElementGetReportID(elem);
    const uint32_t report_size = IOHIDElementGetReportSize(elem);
    const uint32_t report_count = IOHIDElementGetReportCount(elem);
    const uint32_t unit = IOHIDElementGetUnit(elem);
    const uint32_t unit_exponent = IOHIDElementGetUnitExponent(elem);
    const CFIndex logical_min = IOHIDElementGetLogicalMin(elem);
    const CFIndex logical_max = IOHIDElementGetLogicalMax(elem);
    const CFIndex physical_min = IOHIDElementGetPhysicalMin(elem);
    const CFIndex physical_max = IOHIDElementGetPhysicalMax(elem);
    
    
    printf("name=%s, usage_page=%u, usage=0x%x, unit=%u, type=%s, length=%ld\n",
           CFStringGetCStringPtr(name,kCFStringEncodingUTF8), usage_page, usage, unit, input_types[type], length);
}

static void handle_device_report
(
    void * _Nullable    context,
    IOReturn            result,
    void * _Nullable    sender,
    IOHIDReportType     type,
    uint32_t            reportID,
    uint8_t *           report,
    CFIndex             reportLength
)
{
    ViewController *self = (__bridge ViewController *)context;
    ++self.num_reports;
//    printf("%s(context: %p, result: %i, sender: %p, type: %i, reportID:%i).\n\treport:",
//           __PRETTY_FUNCTION__, context, result, sender, type, reportID);
//    for(int i = 0; i < reportLength; ++i)
//    {
//        printf(" 0x%02x", report[i]);
//    }
}

@end
