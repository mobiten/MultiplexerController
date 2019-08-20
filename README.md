![mobiten MultiplexerController](https://raw.githubusercontent.com/mobiten/MultiplexerController/master/logo.png)

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MultiplexerController.svg)](https://img.shields.io/cocoapods/v/MultiplexerController.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Platform](https://img.shields.io/cocoapods/p/MultiplexerController.svg?style=flat)

---

When designing an app, you often have to present different views depending on the state. UIViewController containment is a good solution to reuse your view code and storyboards but it can become tedious to manage their insertion and removal, execute the transitions correctly and do the memory housekeeping.
This is where MultiplexerController can help by creating a container that present its content as a function of the state.

- [x]	It calls `addChild`, `removeChild` and all the callbacks needed
- [x]	Handles the view insertion and removal
- [x]	Presents a nice fade if you want it
- [x]	Deals with the memory as it should
- [x]	Is bit sized with less than 200 lines so you can precisely check what it does

## Requirements

- iOS 10.0+
- Swift 4.2+

## Installation

### CocoaPods

To integrate MultiplexerController into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'MultiplexerController', '~> 1.0.0'
```

### Carthage

To integrate MultiplexerController into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "mobiten/MultiplexerController" "1.0.0"
```
## Usage

A common usage of this library is the presentation of a loading screen and error states.
We will use this enum for the following example:

```swift
enum State {
    case loading
    case loaded(WeatherForecast)
    case error(Error)
}
```

First, create a MultiplexerController with an initial state.
Then, provide it with a DataSource, it can be self or any other class implementing the MultiplexerControllerDataSource protocol.

```swift
let multiplexer = MultiplexerController(initialState: State.loading)
multiplexer.setDataSource(self)
```

Second, implement the protocol in your data source.
```swift
extension HomeController: MultiplexerControllerDataSource {
    func controller(for controller: MultiplexerController<State>, inState state: State) -> UIViewController {
        switch state {
        case .loading:
            return LoadingController()
        case .error(let error):
            return ErrorController(error)
        case .loaded(let forecast):
            return WeatherForecastController(forecast)
        }
    }
}
```

Third, change the state when you need it!
```swift
func didFetch(forecast: WeatherForecast) {
  multiplexer.set(.loaded(forecast), animated: true)
}
```

## FAQ
### Why can't I subclass MultiplexerController?
When possible, you should always prefer composition over inheritance. If you want to use MultiplexerController, embed it in another container or just directly push it to your navigation stack.

### Why is the data source protocol forcing me to use the same type as the initial state?
By forcing you to use the same type (enum is highly recommended) you always know what to expect. As a side effect, if you use an exhaustive switch statement, you will get a nice compiler error when you add a new case to your possible state, reminding you to handle it gracefully in the app. 