# LTPrivacyPermission

LTPrivacyPermission is a library for accessing various system privacy permissions

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
- Calendar Event
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

example:

```objc
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
```

## Reference link

* [PrivacyPermission](https://github.com/skooal/PrivacyPermission)

## License

`LTPrivacyPermission` use [**MIT license**](https://github.com/GREENBANYAN/PrivacyPermission/blob/master/LICENSE "MIT License"	)

