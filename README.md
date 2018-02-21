# SpatialCanvas

SpatialCanvas is an iOS SDK meant to enhance your application by providing a persistent augmented reality experience.

## Requirements

- iOS 11.3+
- ARKit 1.5+

## Install

For now, the SDK only supports [CocoaPods](https://cocoapods.org/) as its install method.

```ruby
pod 'SpatialCanvas', '~> 0.5'
```

In your application Info.plist, add the following property:

```XML
<key>NSLocationWhenInUseUsageDescription</key>
<string>This application will use the location for Augmented Reality persistence.</string>
```

## Documentation

Check the full documentation [here](http://docs.spatialcanvas.com).

## Example

In order to checkout the example:

```shell
git clone git@github.com:spatialcanvas/spatialcanvas-ios.git
cd spatialcanvas-ios/Example
pod repo update
pod install
open Example.xcworkspace
```
