# LTPrivacyPermission 

LTPrivacyPermission is a library for accessing/checking various system privacy permissions

![License](https://img.shields.io/badge/License-MIT-orange.svg)&nbsp;
![Platform](https://img.shields.io/badge/Platform-iOS-yellowgreen.svg)&nbsp;
![Support](https://img.shields.io/badge/Support-iOS%208%2B-lightgrey.svg)&nbsp;
![Cocoapods](https://img.shields.io/badge/cocoapods-support-red.svg)&nbsp;
![Language](https://img.shields.io/badge/language-Objective--C-B9D3EE.svg)&nbsp;

## Privacy Permission Supported
- Photo 
    - Privacy - Photo Library Usage Description
- Camera    
    - Privacy - Camera Usage Description
- Media Library    
    - Privacy - Media Library Usage Description
- Microphone    
    - Privacy - Microphone Usage Description
- Location
    - Privacy - Location Always and When In Use Usage Description   
    - Privacy - Location Always Usage Description   
    - Privacy - Location When In Use Usage Description    
- PushNotification    
- Speech    
    - Privacy - Speech Recognition Usage Description
- Calendar    
    - Privacy - Calendars Usage Description
- Contact    
    - Privacy - Contacts Usage Description
- Reminder    
    - Privacy - Reminders Usage Description 
- Network (for China)

## Preview

 mainpage CN  | mainpage USA
  -----|-----
 ![Asset/permission_zh](https://github.com/lightank/LTPrivacyPermission/blob/master/Assert/permission_zh.png) |  ![Asset/permission_en](https://github.com/lightank/LTPrivacyPermission/blob/master/Assert/permission_en.png) 
 ---  

## Installation with cocoapods

```ruby
 pod 'LTPrivacyPermission'
```

## Usage

- [Start the project to see more example](./LTPrivacyPermissionDemo)

Since the code for the application permission was written, but the corresponding key is not configured in /Info.plist/, the binary submitted for review is rejected after a certain version. The rejected sample information is as follows:

```
 This app attempts to access privacy-sensitive data without a usage description. The app's Info.plist must contain an NSPhotoLibraryUsageDescription key with a string value explaining to the user how the app uses this data.
```

Therefore, this library uses macros to compile. Since it supports `cocoapods`, it may not be possible to modify the `.h` file. It is recommended to define the following macro definition in the pch file. Which macro is required for which permission, or self-built A `LTPrivacyPermissionHeader.h` defines the required macro in this .h file

```
#define LT_Permission_Photo    //0, 
#define LT_Permission_Camera   //1, 
#define LT_Permission_Microphone //2, 
#define LT_Permission_Location_WhenInUse   //3, 
#define LT_Permission_Location_Always  //4, 
#define LT_Permission_Location_AlwaysAndWhenInUse  //5, 
#define LT_Permission_Contact   //6, 
#define LT_Permission_PushNotification //7, 
#define LT_Permission_MediaLibrary //8, 
#define LT_Permission_Speech   //9, 
#define LT_Permission_Calendar //10, 
#define LT_Permission_Reminder  //11, 
#define LT_Permission_Network //12, 
```


example:

```objc
//access：
[LTPrivacyPermission.sharedPermission accessPrivacyPermissionWithType:indexPath.row completion:^(BOOL authorized, LTPrivacyPermissionAuthorizationStatus status) {
    if (!authorized)
    {
        // show open application settings alert
        [LTPrivacyPermission showOpenApplicationSettingsAlertWithTitle:NSLocalizedString(@"Permission.ErrorTitle", nil) message:NSLocalizedString(@"Permission.ErrorTitleInfo", nil) cancelActionTitle:NSLocalizedString(@"Permission.ErrorCancel", nil) settingActionTitle:NSLocalizedString(@"Permission.ErrorOpenSetting", nil)];
    }
    else
    {
        // do something you want to do
    }
}];


//check：
[LTPrivacyPermission.sharedPermission checkPrivacyPermissionWithType:indexPath.row completion:^(BOOL authorized, LTPrivacyPermissionType type, LTPrivacyPermissionAuthorizationStatus status) {
    if (!authorized)
    {
        [LTPrivacyPermission showOpenApplicationSettingsAlertWithTitle:NSLocalizedString(@"Permission.ErrorTitle", nil) message:NSLocalizedString(@"Permission.ErrorTitleInfo", nil) cancelActionTitle:NSLocalizedString(@"Permission.ErrorCancel", nil) settingActionTitle:NSLocalizedString(@"Permission.ErrorOpenSetting", nil)];
    }
}];

```

## Reference link

* [PrivacyPermission](https://github.com/skooal/PrivacyPermission)

## License

`LTPrivacyPermission` use [**MIT license**](https://github.com/GREENBANYAN/PrivacyPermission/blob/master/LICENSE "MIT License"	)

