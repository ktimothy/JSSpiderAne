SpiderMonkey-AIR-ANE
====================

Javascript for Adobe AIR. Also, please **read this README**!

State: *Alpha. Keep calm and wait for updates*
=====

This Open-Source project is funded personally by [Denis Novozhilov](https://github.com/gloomybrain).

The main idea of the project is to be able to perform identical **Haxe** (JavaScript) code on the client and server. It provides a fairly simple interface to the JS on the CQRS principle (https://en.wikipedia.org/wiki/Command-query_separation)

Perhaps with the help of reflection its capabilities will be greatly enhanced.
Information is shared with the help of JSON objects.

There are plans to support platforms such as mac, windows, ios and android.

Download the **ane** file and take a look at the **demo** folder. It's very simple!

Supported Platforms
=====

- Mac 32bit
- iOS 6+7+8 32bit
- iOS Sim 32bit
- Android ARMv7
- Android x86

How To Build SpiderMonkey
=====

- Execute build/build_sm.sh
- Wait...
- Done!

How To Build ANE
=====

- Change configure/*.txt
- Execute build/build_ane.sh
- Build scripts uses chaching for speed-up of builds
- Here is ane/JSSpiderANE.ane

How To Automate FULL (Re-)Build
=====

- Change configure/*.txt
- Just execute build.sh in build folder
- Requires Mac 5K Retina, XCode, Android NDK, AIR SDK / Apache Flex, GCC
