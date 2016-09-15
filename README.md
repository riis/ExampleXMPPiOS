# XMPP iOS Example

## Dependency Installation (CocoaPods)

Before you can build the XCode project, you must first properly install the CocoaPod dependencies to the project.  To install these dependencies, navigate to the base directory of the project and run the following commands:

```sh
$ pod install
$ pod update
```

If you do not have CocoaPods currently on you machine, run the following command to install it:

```sh
$ sudo gem install cocoapods
```

Once the all of the dependencies are installed and updated, you can now open the project in XCode.  After launching XCode, open the project using the **.xcworkspace** file.

## Fix Before Build

There is an error in one of the methods inside one of the Pod libraries that needs to fixed before the project will compile correctly.  Inside of the **xmpp-messanger-ios** directory, locate the **OneChat.swift** file and change the following lines of code in the **setupStream()** method:

```sh
xmppvCardTempModule = XMPPvCardTempModule(withvCardStorage: xmppvCardStorage)
xmppvCardAvatarModule = XMPPvCardAvatarModule(withvCardTempModule: xmppvCardTempModule)
```
to:
```sh
xmppvCardTempModule = XMPPvCardTempModule(vCardStorage: xmppvCardStorage)
xmppvCardAvatarModule = XMPPvCardAvatarModule(vCardTempModule: xmppvCardTempModule)
```

Now you can compile the project and launch the app on the device of your choosing.
