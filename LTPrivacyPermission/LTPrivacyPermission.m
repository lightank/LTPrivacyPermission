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
/**  定位回调  */
@property (nonatomic, copy) LTPrivacyPermissionCompletionBlock locationCompletion;

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

- (void)accessPrivacyPermissionWithType:(LTPrivacyPermissionType)type
                             completion:(LTPrivacyPermissionCompletionBlock)completion
{
    completion = completion ? : ^(BOOL authorized, LTPrivacyPermissionAuthorizationStatus status) {
        
    };
    
    switch (type)
    {
        case LTPrivacyPermissionTypePhoto:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status)
                    {
                        case PHAuthorizationStatusNotDetermined:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusNotDetermined);
                            break;
                            
                        case PHAuthorizationStatusRestricted:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                            break;
                            
                        case PHAuthorizationStatusDenied:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                            break;
                            
                        case PHAuthorizationStatusAuthorized:
                            completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                            break;
                    }
                });
            }];
        }
            break;
            
        case LTPrivacyPermissionTypeCamera:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status)
                    {
                        case AVAuthorizationStatusNotDetermined:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusNotDetermined);
                            break;
                            
                        case AVAuthorizationStatusRestricted:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                            break;
                            
                        case AVAuthorizationStatusDenied:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                            break;
                            
                        case AVAuthorizationStatusAuthorized:
                            completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                            break;
                    }
                });
            }];
        }
            break;
            
        case LTPrivacyPermissionTypeMediaLibrary:
        {
#ifdef LTLTPrivacyPermissionMediaLibraryAvailable
            if (@available(iOS 9.3, *)) {
                [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        switch (status)
                        {
                            case MPMediaLibraryAuthorizationStatusNotDetermined:
                                completion(NO, LTPrivacyPermissionAuthorizationStatusNotDetermined);
                                break;
                                
                            case MPMediaLibraryAuthorizationStatusDenied:
                                completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                                break;
                                
                            case MPMediaLibraryAuthorizationStatusRestricted:
                                completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                                break;
                                
                            case MPMediaLibraryAuthorizationStatusAuthorized:
                                completion(YES, LTPrivacyPermissionAuthorizationStatusNotDetermined);
                                break;
                        }
                    });
                }];
            }
#elif
                completion(self.isServicesDisabledAuthorize, LTPrivacyPermissionAuthorizationStatusServicesDisabled);
#endif
        }
            break;
            
        case LTPrivacyPermissionTypeMicrophone:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
                switch (status)
                {
                    case AVAuthorizationStatusDenied:
                        completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                        break;

                    case AVAuthorizationStatusNotDetermined:
                        completion(NO, LTPrivacyPermissionAuthorizationStatusNotDetermined);
                        break;

                    case AVAuthorizationStatusRestricted:
                        completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                        break;

                    case AVAuthorizationStatusAuthorized:
                        completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                        break;
                }
            }];
        }
            break;
            
        case LTPrivacyPermissionTypeLocationAlways:
        case LTPrivacyPermissionTypeLocationWhenInUse:
        case LTPrivacyPermissionTypeLocationAlwaysAndWhenInUse:
        {
            if (![CLLocationManager locationServicesEnabled])
            {
                completion(self.isServicesDisabledAuthorize, LTPrivacyPermissionAuthorizationStatusServicesDisabled);
                break;
            }
            
            CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
            switch (status)
            {
                case kCLAuthorizationStatusNotDetermined:
                {
                    self.locationCompletion = completion;
                    
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
                    break;
                    
                case kCLAuthorizationStatusDenied:
                    completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                    break;
                    
                case kCLAuthorizationStatusAuthorizedAlways:
                    completion(YES, LTPrivacyPermissionAuthorizationStatusLocationAlways);
                    break;
                    
                case kCLAuthorizationStatusAuthorizedWhenInUse:
                    completion(YES, LTPrivacyPermissionAuthorizationStatusLocationWhenInUse);
                    break;
                    
                case kCLAuthorizationStatusRestricted:
                    completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                    break;
            }
        }
            break;
            
        case LTPrivacyPermissionTypePushNotification:
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
                            UNAuthorizationOptions types = UNAuthorizationOptionBadge | UNAuthorizationOptionAlert |UNAuthorizationOptionSound;
                            [center requestAuthorizationWithOptions:types completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    completion(granted, granted ? LTPrivacyPermissionAuthorizationStatusAuthorized : LTPrivacyPermissionAuthorizationStatusDenied);
                                });
                            }];
                        }
                            break;
                            
                        case UNAuthorizationStatusDenied:
                        {
                            completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                        }
                            break;
                            
                        case UNAuthorizationStatusAuthorized:
                        case UNAuthorizationStatusProvisional:
                        {
                            completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
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
                        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
                        completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                    }
                        break;
                    case UIUserNotificationTypeBadge:
                    case UIUserNotificationTypeSound:
                    case UIUserNotificationTypeAlert:
                    {
                        completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                    }
                        break;
                    default:
                        break;
                }
#pragma clang diagnostic pop
#endif
        }
            break;
            
        case LTPrivacyPermissionTypeSpeech:
        {
#ifdef LTLTPrivacyPermissionSpeechAvailable
            if (@available(iOS 10.0, *)) {
                [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        switch (status)
                        {
                            case SFSpeechRecognizerAuthorizationStatusDenied:
                                completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                                break;
                                
                            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                                completion(NO, LTPrivacyPermissionAuthorizationStatusNotDetermined);
                                break;
                                
                            case SFSpeechRecognizerAuthorizationStatusRestricted:
                                completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                                break;
                                
                            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                                completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                                break;
                        }
                    });
                }];
            }
#elif
            completion(self.isServicesDisabledAuthorize, LTPrivacyPermissionAuthorizationStatusServicesDisabled);
#endif
        }
            break;
            
        case LTPrivacyPermissionTypeCalendar:
        {
            EKEventStore *store = [[EKEventStore alloc] init];
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status)
                    {
                        case EKAuthorizationStatusAuthorized:
                            completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                            break;
                            
                        case EKAuthorizationStatusDenied:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                            break;
                            
                        case EKAuthorizationStatusNotDetermined:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusNotDetermined);
                            break;
                            
                        case EKAuthorizationStatusRestricted:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                            break;
                    }
                });
            }];
        }
            break;
            
        case LTPrivacyPermissionTypeContact:
        {
#ifdef  LTLTPrivacyPermissionContactAvailable
            if (@available(iOS 9.0, *))
            {
                CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
                switch (status)
                {
                    case CNAuthorizationStatusAuthorized:
                        completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                        break;
                        
                    case CNAuthorizationStatusDenied:
                        completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                        break;
                        
                    case CNAuthorizationStatusRestricted:
                        completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                        break;
                        
                    case CNAuthorizationStatusNotDetermined:
                    {
                        [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(granted, granted ? LTPrivacyPermissionAuthorizationStatusAuthorized : LTPrivacyPermissionAuthorizationStatusDenied);
                            });
                        }];
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
                        completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                    }
                        break;
                        
                    case kABAuthorizationStatusNotDetermined:
                    {
                        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                completion(granted, granted ? LTPrivacyPermissionAuthorizationStatusAuthorized : LTPrivacyPermissionAuthorizationStatusDenied);
                            });
                        });
                    }
                        break;
                        
                    case kABAuthorizationStatusRestricted:
                    {
                        completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                    }
                        break;
                        
                    case kABAuthorizationStatusDenied:
                    {
                        completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                    }
                        break;
                }
            }
#pragma clang diagnostic pop
#endif
            
        }
            break;
            
        case LTPrivacyPermissionTypeReminder:
        {
            EKEventStore *eventStore = [[EKEventStore alloc] init];
            [eventStore requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
                EKAuthorizationStatus status = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (status)
                    {
                        case EKAuthorizationStatusNotDetermined:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusNotDetermined);
                            break;
                            
                        case EKAuthorizationStatusRestricted:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
                            break;
                            
                        case EKAuthorizationStatusDenied:
                            completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                            break;
                            
                        case EKAuthorizationStatusAuthorized:
                            completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                            break;
                    }
                });
            }];
        }
            break;
            
            
        case LTPrivacyPermissionTypeNetwork:
        {
#ifdef LTLTPrivacyPermissionCoreTelephonyAvailable
                CTCellularData *cellularData = [[CTCellularData alloc] init];
                CTCellularDataRestrictedState status = cellularData.restrictedState;
                
                switch (status)
                {
                    case kCTCellularDataNotRestricted:
                    {
                        //没有限制
                        completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                    }
                        break;
                        
                    case kCTCellularDataRestricted:
                    {
                        //限制
                        completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                    }
                        break;
                        
                    case kCTCellularDataRestrictedStateUnknown:
                    {
                        [cellularData setCellularDataRestrictionDidUpdateNotifier:^(CTCellularDataRestrictedState newState) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                switch (newState)
                                {
                                    case kCTCellularDataNotRestricted:
                                    {
                                        //没有限制
                                        completion(YES, LTPrivacyPermissionAuthorizationStatusAuthorized);
                                    }
                                        break;
                                        
                                    case kCTCellularDataRestricted:
                                    {
                                        //限制
                                        completion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
                                    }
                                        break;
                                    
                                    case kCTCellularDataRestrictedStateUnknown:
                                    {
                                        completion(NO, LTPrivacyPermissionAuthorizationStatusUnkonwn);
                                    }
                                        break;
                                }
                            });
                        }];
                    }
                        break;
                }
#elif
        completion(self.isServicesDisabledAuthorize, LTPrivacyPermissionAuthorizationStatusServicesDisabled);
#endif
        }
            break;
    }
}

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
    if (!self.locationCompletion)
    {
        return;
    }
    
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
            // 默认会走一遍,所以这个默认什么都不做
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            self.locationCompletion(YES, LTPrivacyPermissionAuthorizationStatusLocationWhenInUse);
            self.locationCompletion = nil;
        }
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            self.locationCompletion(YES, LTPrivacyPermissionAuthorizationStatusLocationAlways);
            self.locationCompletion = nil;
        }
            break;
            
        case kCLAuthorizationStatusDenied:
        {
            self.locationCompletion(NO, LTPrivacyPermissionAuthorizationStatusDenied);
            self.locationCompletion = nil;
        }
            break;
            
        case kCLAuthorizationStatusRestricted:
        {
            self.locationCompletion(NO, LTPrivacyPermissionAuthorizationStatusRestricted);
            self.locationCompletion = nil;
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
