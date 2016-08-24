# Nariko

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

Create a Settings.bundle in your project based on the Example Project. The bundle have to contain two rows
- Text Field with identifier: nar_email
- Text Field with identifier: nar_pass and secure text type


## Installation

Nariko is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:


```ruby
pod "Nariko"
```

## Usage

The usage of the tool is really simple. You have to make a Settings.bundle in your project as it described above than you have to add a few line in the Appdelegate.

```swift
import Nariko
```
and

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

NarikoTool.sharedInstance.checkAuth()
self.window!.rootViewController!.view.addGestureRecognizer(BubbleTapGestureRecognizer())
self.window!.rootViewController!.view.addGestureRecognizer(BubbleLongPressGestureRecognizer())

return true
}
```

If you included the tool properly you can use it with a 3 fingers long tap for 3 seconds

## Author

Zednet Informatika Kft., info@nariko.io

## License

Nariko is available under the MIT license. See the LICENSE file for more info.
=======
# nariko

