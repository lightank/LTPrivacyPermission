//
//  LTPrivacyPermission.m
//  UniversalApp
//
//  Created by huanyu.li on 2018/8/24.
//  Copyright © 2018年 huanyu.li. All rights reserved.
//

#import "LTPrivacyPermission.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <EventKit/EventKit.h>
#import <AddressBook/AddressBook.h>
#import <HealthKit/HealthKit.h>
#import <CoreLocation/CoreLocation.h>

#if __has_include(<CoreTelephony/CTCellularData.h>)
#import <CoreTelephony/CTCellularData.h>

#ifndef LTLTPrivacyPermissionCoreTelephonyAvailable
#define LTLTPrivacyPermissionCoreTelephonyAvailable
#endif

#endif

#if __has_include(<Speech/Speech.h>)
#import <Speech/Speech.h>

#ifndef LTLTPrivacyPermissionSpeechAvailable
#define LTLTPrivacyPermissionSpeechAvailable
#endif

#endif

#if __has_include(<MediaPlayer/MediaPlayer.h>)
#import <MediaPlayer/MediaPlayer.h>

#ifndef LTLTPrivacyPermissionMediaLibraryAvailable
#define LTLTPrivacyPermissionMediaLibraryAvailable
#endif

#endif

#if __has_include(<Contacts/Contacts.h>)
#import <Contacts/Contacts.h>

#ifndef LTLTPrivacyPermissionContactAvailable
#define LTLTPrivacyPermissionContactAvailable
#endif

#endif

#if __has_include(<UserNotifications/UserNotifications.h>)
#import <UserNotifications/UserNotifications.h>

#ifndef LTLTPrivacyPermissionUserNotificationsAvailable
#define LTLTPrivacyPermissionUserNotificationsAvailable
#endif

#endif

@interface LTPrivacyPermission () <CLLocationManagerDelegate>

/**  定位  */
@property (nonatomic, strong) CLLocationManager *locationManager;

/**  完成回调  */
@property (nonatomic, copy) LTPrivacyPermissionCompletionBlock completionBlock;

@end


@implementation LTPrivacyPermission

+ (LTPrivacyPermission *)sharedPermission
{
    static dispatch_once_t onceToken;
    static LTPrivacyPermission *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedPermission];
}

- (void)privacyPermissionWithType:(LTPrivacyPermissionType)type
                       completion:(LTPrivacyPermissionCompletionBlock)completion
        shouldAccessAuthorization:(BOOL)access
{
    self.completionBlock = completion;
    switch (type)
    {
        case LTPrivacyPermissionTypePhoto:
            [self PhotoAuthorizationWhetherAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeCamera:
            [self AVCaptureDeviceAuthorizationStatusForMediaType:AVMediaTypeVideo shouldAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeMediaLibrary:
            [self MediaLibraryAuthorizationWhetherAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeMicrophone:
            [self AVCaptureDeviceAuthorizationStatusForMediaType:AVMediaTypeAudio shouldAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeLocationAlways:
            [self LocationAuthorizationStatusForMediaType:LTPrivacyPermissionTypeLocationAlways shouldAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeLocationWhenInUse:
            [self LocationAuthorizationStatusForMediaType:LTPrivacyPermissionTypeLocationWhenInUse shouldAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeLocationAlwaysAndWhenInUse:
            [self LocationAuthorizationStatusForMediaType:LTPrivacyPermissionTypeLocationWhenInUse shouldAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypePushNotification:
            [self PushNotificationAuthorizationWhetherAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeSpeech:
            [self SpeechAuthorizationWhetherAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeCalendar:
            [self EKEventStoreAuthorizationStatusForEntityType:EKEntityTypeEvent shouldAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeContact:
            [self ContactAuthorizationWhetherAccessAuthorization:access];
            break;
        
        case LTPrivacyPermissionTypeReminder:
            [self EKEventStoreAuthorizationStatusForEntityType:EKEntityTypeReminder shouldAccessAuthorization:access];
            break;
            
        case LTPrivacyPermissionTypeNetwork:
            [self NetworkAuthorizationWhetherAccessAuthorization:access];
            break;
    }
}


- (void)accessPrivacyPermissionWithType:(LTPrivacyPermissionType)type
                             completion:(LTPrivacyPermissionCompletionBlock)completion
{
    [self privacyPermissionWithType:type completion:completion shouldAccessAuthorization:YES];
}

- (void)checkPrivacyPermissionWithType:(LTPrivacyPermissionType)type
                            completion:(LTPrivacyPermissionCompletionBlock)completion
{
    [self privacyPermissionWithType:type completion:completion shouldAccessAuthorization:NO];
}

- (void)completionWithAuthorized:(BOOL)authorized authorizationStatus:(LTPrivacyPermissionAuthorizationStatus)status
{
    if (self.completionBlock)
    {
        if ([NSThread currentThread].isMainThread)
        {
            self.completionBlock(authorized, status);
            self.completionBlock = nil;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionBlock(authorized, status);
                self.completionBlock = nil;
            });
        }
    }
}

#pragma mark - 单个授权

- (void)PhotoAuthorizationWhetherAccessAuthorization:(BOOL)access
{
    if (access)
    {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (status)
                {
                    case PHAuthorizationStatusNotDetermined:
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                        break;
                        
                    case PHAuthorizationStatusRestricted:
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                        break;
                        
                    case PHAuthorizationStatusDenied:
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                        break;
                        
                    case PHAuthorizationStatusAuthorized:
                        [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                        break;
                }
            });
        }];
    }
    else
    {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        switch (status)
        {
            case PHAuthorizationStatusNotDetermined:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                break;
                
            case PHAuthorizationStatusRestricted:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                break;
                
            case PHAuthorizationStatusDenied:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                break;
                
            case PHAuthorizationStatusAuthorized:
                [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                break;
        }

    }
}

- (void)AVCaptureDeviceAuthorizationStatusForMediaType:(AVMediaType)mediaType shouldAccessAuthorization:(BOOL)access
{
    if (access)
    {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (status)
                {
                    case AVAuthorizationStatusNotDetermined:
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                        break;
                        
                    case AVAuthorizationStatusRestricted:
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                        break;
                        
                    case AVAuthorizationStatusDenied:
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                        break;
                        
                    case AVAuthorizationStatusAuthorized:
                        [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                        break;
                }
            });
        }];
    }
    else
    {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        switch (status)
        {
            case AVAuthorizationStatusNotDetermined:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                break;
                
            case AVAuthorizationStatusRestricted:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                break;
                
            case AVAuthorizationStatusDenied:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                break;
                
            case AVAuthorizationStatusAuthorized:
                [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                break;
        }
    }
}

- (void)MediaLibraryAuthorizationWhetherAccessAuthorization:(BOOL)access
{
    if (access)
    {
#ifdef LTLTPrivacyPermissionMediaLibraryAvailable
        if (@available(iOS 9.3, *)) {
            [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status)
                    {
                        case MPMediaLibraryAuthorizationStatusNotDetermined:
                            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                            break;
                            
                        case MPMediaLibraryAuthorizationStatusDenied:
                            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                            break;
                            
                        case MPMediaLibraryAuthorizationStatusRestricted:
                            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                            break;
                            
                        case MPMediaLibraryAuthorizationStatusAuthorized:
                            [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                            break;
                    }
                });
            }];
        }
#elif
        [self completionWithAuthorized:self.isServicesDisabledAuthorize authorizationStatus:LTPrivacyPermissionAuthorizationStatusServicesDisabled];
#endif
    }
    else
    {
#ifdef LTLTPrivacyPermissionMediaLibraryAvailable
        if (@available(iOS 9.3, *))
        {
            MPMediaLibraryAuthorizationStatus status = [MPMediaLibrary authorizationStatus];
            switch (status)
            {
                case MPMediaLibraryAuthorizationStatusNotDetermined:
                    [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                    break;
                    
                case MPMediaLibraryAuthorizationStatusDenied:
                    [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                    break;
                    
                case MPMediaLibraryAuthorizationStatusRestricted:
                    [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                    break;
                    
                case MPMediaLibraryAuthorizationStatusAuthorized:
                    [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                    break;
            }
        }
#elif
        [self completionWithAuthorized:self.isServicesDisabledAuthorize authorizationStatus:LTPrivacyPermissionAuthorizationStatusServicesDisabled];
#endif
    }
}

- (void)LocationAuthorizationStatusForMediaType:(LTPrivacyPermissionType)type shouldAccessAuthorization:(BOOL)access
{
    BOOL isLocation = (type == LTPrivacyPermissionTypeLocationAlways || type == LTPrivacyPermissionTypeLocationWhenInUse || type == LTPrivacyPermissionTypeLocationAlwaysAndWhenInUse);
    if (!isLocation)
    {
        return;
    }
    
    if (![CLLocationManager locationServicesEnabled])
    {
        [self completionWithAuthorized:self.isServicesDisabledAuthorize authorizationStatus:LTPrivacyPermissionAuthorizationStatusServicesDisabled];
        return;
    }
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
        {
            if (access)
            {
                switch (type)
                {
                    case LTPrivacyPermissionTypeLocationAlways:
                    {
                        [self.locationManager requestAlwaysAuthorization];
                    }
                        break;
                        
                    case LTPrivacyPermissionTypeLocationWhenInUse:
                    {
                        [self.locationManager requestWhenInUseAuthorization];
                    }
                        break;
                        
                    case LTPrivacyPermissionTypeLocationAlwaysAndWhenInUse:
                    {
                        [self.locationManager requestAlwaysAuthorization];
                        [self.locationManager requestWhenInUseAuthorization];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
            else
            {
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
            }
        }
            break;
            
        case kCLAuthorizationStatusDenied:
            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
            [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusLocationAlways];
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusLocationWhenInUse];
            break;
            
        case kCLAuthorizationStatusRestricted:
            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
            break;
    }
}

- (void)PushNotificationAuthorizationWhetherAccessAuthorization:(BOOL)access
{
#ifdef LTLTPrivacyPermissionUserNotificationsAvailable
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            UNAuthorizationStatus status = settings.authorizationStatus;
            switch (status)
            {
                case UNAuthorizationStatusNotDetermined:
                {
                    if (access)
                    {
                        UNAuthorizationOptions types = UNAuthorizationOptionBadge | UNAuthorizationOptionAlert |UNAuthorizationOptionSound;
                        [center requestAuthorizationWithOptions:types completionHandler:^(BOOL granted, NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self completionWithAuthorized:granted authorizationStatus:granted ? LTPrivacyPermissionAuthorizationStatusAuthorized : LTPrivacyPermissionAuthorizationStatusDenied];
                            });
                        }];
                    }
                    else
                    {
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                    }
                }
                    break;
                    
                case UNAuthorizationStatusDenied:
                {
                    [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                }
                    break;
                    
                case UNAuthorizationStatusAuthorized:
                case UNAuthorizationStatusProvisional:
                {
                    [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                }
                    break;
                    
                default:
                    break;
            }
            
        }];
    }
#else
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    UIUserNotificationType status = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    switch (status)
    {
        case UIUserNotificationTypeNone:
        {
            if (access)
            {
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
            }
            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
        }
            break;
        case UIUserNotificationTypeBadge:
        case UIUserNotificationTypeSound:
        case UIUserNotificationTypeAlert:
        {
            [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
        }
            break;
        default:
            break;
    }
#pragma clang diagnostic pop
#endif
}

- (void)SpeechAuthorizationWhetherAccessAuthorization:(BOOL)access
{
    if (access)
    {
#ifdef LTLTPrivacyPermissionSpeechAvailable
        if (@available(iOS 10.0, *)) {
            [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status)
                    {
                        case SFSpeechRecognizerAuthorizationStatusDenied:
                            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                            break;
                            
                        case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                            break;
                            
                        case SFSpeechRecognizerAuthorizationStatusRestricted:
                            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                            break;
                            
                        case SFSpeechRecognizerAuthorizationStatusAuthorized:
                            [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                            break;
                    }
                });
            }];
        }
#elif
        [self completionWithAuthorized:self.isServicesDisabledAuthorize authorizationStatus:LTPrivacyPermissionAuthorizationStatusServicesDisabled];
#endif

    }
    else
    {
#ifdef LTLTPrivacyPermissionSpeechAvailable
        if (@available(iOS 10.0, *))
        {
            SFSpeechRecognizerAuthorizationStatus status = [SFSpeechRecognizer authorizationStatus];
            switch (status)
            {
                case SFSpeechRecognizerAuthorizationStatusDenied:
                    [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                    break;
                    
                case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                    [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                    break;
                    
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                    [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                    break;
                    
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                    [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                    break;
            }
        }
#elif
        [self completionWithAuthorized:self.isServicesDisabledAuthorize authorizationStatus:LTPrivacyPermissionAuthorizationStatusServicesDisabled];
#endif

    }
}

- (void)ContactAuthorizationWhetherAccessAuthorization:(BOOL)access
{
#ifdef  LTLTPrivacyPermissionContactAvailable
    if (@available(iOS 9.0, *))
    {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (status)
        {
            case CNAuthorizationStatusAuthorized:
                [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                break;
                
            case CNAuthorizationStatusDenied:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                break;
                
            case CNAuthorizationStatusRestricted:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                break;
                
            case CNAuthorizationStatusNotDetermined:
            {
                if (access)
                {
                    [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self completionWithAuthorized:granted authorizationStatus:granted ? LTPrivacyPermissionAuthorizationStatusAuthorized : LTPrivacyPermissionAuthorizationStatusDenied];
                        });
                    }];
                }
                else
                {
                    [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                }
            }
                break;
        }
    }
#elif
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status)
    {
        case kABAuthorizationStatusAuthorized:
        {
            [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
        }
            break;
            
        case kABAuthorizationStatusNotDetermined:
        {
            if (access)
            {
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self completionWithAuthorized:granted authorizationStatus:granted ? LTPrivacyPermissionAuthorizationStatusAuthorized : LTPrivacyPermissionAuthorizationStatusDenied];
                    });
                });
            }
            else
            {
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
            }
        }
            break;
            
        case kABAuthorizationStatusRestricted:
        {
            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
        }
            break;
            
        case kABAuthorizationStatusDenied:
        {
            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
        }
            break;
    }
#pragma clang diagnostic pop
#endif
}

- (void)EKEventStoreAuthorizationStatusForEntityType:(EKEntityType)type shouldAccessAuthorization:(BOOL)access
{
    if (access)
    {
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        [eventStore requestAccessToEntityType:type completion:^(BOOL granted, NSError * _Nullable error) {
            EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
            dispatch_async(dispatch_get_main_queue(), ^{
                switch (status)
                {
                    case EKAuthorizationStatusNotDetermined:
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                        break;
                        
                    case EKAuthorizationStatusRestricted:
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                        break;
                        
                    case EKAuthorizationStatusDenied:
                        [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                        break;
                        
                    case EKAuthorizationStatusAuthorized:
                        [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                        break;
                }
            });
        }];
    }
    else
    {
        EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:type];
        switch (status)
        {
            case EKAuthorizationStatusNotDetermined:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
                break;
                
            case EKAuthorizationStatusRestricted:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                break;
                
            case EKAuthorizationStatusDenied:
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
                break;
                
            case EKAuthorizationStatusAuthorized:
                [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                break;
        }
    }
}

- (void)NetworkAuthorizationWhetherAccessAuthorization:(BOOL)access
{
#ifdef LTLTPrivacyPermissionCoreTelephonyAvailable
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    CTCellularDataRestrictedState status = cellularData.restrictedState;
    
    switch (status)
    {
        case kCTCellularDataNotRestricted:
        {
            //没有限制
            [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
        }
            break;
            
        case kCTCellularDataRestricted:
        {
            //限制
            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
        }
            break;
            
        case kCTCellularDataRestrictedStateUnknown:
        {
            if (access)
            {
                [cellularData setCellularDataRestrictionDidUpdateNotifier:^(CTCellularDataRestrictedState newState) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        switch (newState)
                        {
                            case kCTCellularDataNotRestricted:
                            {
                                //没有限制
                                [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusAuthorized];
                            }
                                break;
                                
                            case kCTCellularDataRestricted:
                            {
                                //限制
                                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
                            }
                                break;
                                
                            case kCTCellularDataRestrictedStateUnknown:
                            {
                                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusUnkonwn];
                            }
                                break;
                        }
                    });
                }];
            }
            else
            {
                [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusNotDetermined];
            }
        }
            break;
    }
#elif
    [self completionWithAuthorized:self.isServicesDisabledAuthorize authorizationStatus:LTPrivacyPermissionAuthorizationStatusServicesDisabled];
#endif
}

#pragma mark - 系统设置
+ (void)showOpenApplicationSettingsAlertWithTitle:(NSString *)title
                                          message:(NSString *)message
                                cancelActionTitle:(NSString *)cancelActionTitle
                               settingActionTitle:(NSString *)settingActionTitle
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *settingAction = [UIAlertAction actionWithTitle:settingActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openApplicationSettings];
    }];
    
    [alertVC addAction:cancelAction];
    [alertVC addAction:settingAction];
    
    [self.topmostKeyWindowController presentViewController:alertVC animated:YES completion:^{
        
    }];
}

+ (void)openApplicationSettings
{
    NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:settingURL])
    {
        if (@available(iOS 10.0, *))
        {
            [[UIApplication sharedApplication] openURL:settingURL options:@{} completionHandler:nil];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:settingURL];
        }
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
            // 默认会走一遍,所以这个默认什么都不做
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusLocationWhenInUse];
        }
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            [self completionWithAuthorized:YES authorizationStatus:LTPrivacyPermissionAuthorizationStatusLocationAlways];
        }
            break;
            
        case kCLAuthorizationStatusDenied:
        {
            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusDenied];
        }
            break;
            
        case kCLAuthorizationStatusRestricted:
        {
            [self completionWithAuthorized:NO authorizationStatus:LTPrivacyPermissionAuthorizationStatusRestricted];
        }
            break;
    }
}

#pragma mark - setter and getter
- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

+ (UIViewController *)topmostKeyWindowController
{
    UIViewController *topController = UIApplication.sharedApplication.keyWindow.rootViewController;
    while ([topController presentedViewController])
    {
        topController = [topController presentedViewController];
    }
    
    while ([topController isKindOfClass:[UITabBarController class]]
           && ((UITabBarController*)topController).selectedViewController)
    {
        topController = ((UITabBarController*)topController).selectedViewController;
    }
    
    while ([topController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topController topViewController])
    {
        topController = [(UINavigationController*)topController topViewController];
        
        while ([topController isKindOfClass:[UITabBarController class]]
               && ((UITabBarController*)topController).selectedViewController)
        {
            topController = ((UITabBarController*)topController).selectedViewController;
        }
    }
    
    return topController;
}

@end
