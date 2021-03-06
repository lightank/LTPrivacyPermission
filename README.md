# LTPrivacyPermission 

LTPrivacyPermission 是一个 获取/检测 系统隐私权限的库

![License](https://img.shields.io/badge/License-MIT-orange.svg)&nbsp;
![Platform](https://img.shields.io/badge/Platform-iOS-yellowgreen.svg)&nbsp;
![Support](https://img.shields.io/badge/Support-iOS%208%2B-lightgrey.svg)&nbsp;
![Cocoapods](https://img.shields.io/badge/cocoapods-support-red.svg)&nbsp;
![Language](https://img.shields.io/badge/language-Objective--C-B9D3EE.svg)&nbsp;

## 支持的隐私权限
- Photo    // 相册
    - Privacy - Photo Library Usage Description
- Camera    // 相机
    - Privacy - Camera Usage Description
- Media Library    // 媒体资源库
    - Privacy - Media Library Usage Description
- Microphone    // 麦克风
    - Privacy - Microphone Usage Description
- Location
    - Privacy - Location Always and When In Use Usage Description    // 使用期间/始终访问地理位置
    - Privacy - Location Always Usage Description    // 始终访问地理位置
    - Privacy - Location When In Use Usage Description    //  使用期间访问地理位置
- PushNotification    // 推送
- Speech    // 语音识别
    - Privacy - Speech Recognition Usage Description
- Calendar    // 日历
    - Privacy - Calendars Usage Description
- Contact    // 通讯录
    - Privacy - Contacts Usage Description
- Reminder    // 提醒事项
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

- [运行demo代码查看更多示例](./LTPrivacyPermissionDemo)

由于某个版本后,写了申请权限的代码,但是没有在 /Info.plist/ 中配置相应的key,会导致提交审核的二进制被拒,被拒示例信息如下:

```
 This app attempts to access privacy-sensitive data without a usage description. The app's Info.plist must contain an NSPhotoLibraryUsageDescription key with a string value explaining to the user how the app uses this data.
```

所以此库采用宏来条件编译,由于支持 `cocoapods`,所以可能不能修改 `.h`文件,估建议在pch文件里定义下面的宏定义,需要哪一个权限就选用哪一个宏,或者自建一个 `LTPrivacyPermissionHeader.h` 在这.h文件中定义所需宏

```
#define LT_Permission_Photo    //0, 相册
#define LT_Permission_Camera   //1, 相机
#define LT_Permission_Microphone //2, 麦克风
#define LT_Permission_Location_WhenInUse   //3, 使用期间访问地理位置
#define LT_Permission_Location_Always  //4, 始终访问地理位置
#define LT_Permission_Location_AlwaysAndWhenInUse  //5, 使用期间/始终访问地理位置
#define LT_Permission_Contact   //6, 通讯录
#define LT_Permission_PushNotification //7, 推送
#define LT_Permission_MediaLibrary //8, 媒体资源库
#define LT_Permission_Speech   //9, 语音识别
#define LT_Permission_Calendar //10, 日历
#define LT_Permission_Reminder  //11, 提醒事项
#define LT_Permission_Network //12, 网络
```


部分示例如下:

获取权限：

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
```

检测是否有无权限：

```objc
//check：
[LTPrivacyPermission.sharedPermission checkPrivacyPermissionWithType:indexPath.row completion:^(BOOL authorized, LTPrivacyPermissionType type, LTPrivacyPermissionAuthorizationStatus status) {
    if (!authorized)
    {
        [LTPrivacyPermission showOpenApplicationSettingsAlertWithTitle:NSLocalizedString(@"Permission.ErrorTitle", nil) message:NSLocalizedString(@"Permission.ErrorTitleInfo", nil) cancelActionTitle:NSLocalizedString(@"Permission.ErrorCancel", nil) settingActionTitle:NSLocalizedString(@"Permission.ErrorOpenSetting", nil)];
    }
}];

```

## 引用链接

* [PrivacyPermission](https://github.com/skooal/PrivacyPermission)

## License

`LTPrivacyPermission` use [**MIT license**](https://github.com/GREENBANYAN/PrivacyPermission/blob/master/LICENSE "MIT License"	)

