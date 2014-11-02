Combine splitted zip`s with commands:

```sh
cd ./jni/
cat libjs_staticARM7.a.zip* > ~/libjs_staticARM7.a.zip
zip -T libjs_staticARM7.a.zip
unzip libjs_staticARM7.a.zip
```

Split is done with ```split -b 90m libjs_staticARM7.a.zip libjs_staticARM7.a.zip```

To build:

(so_arm, so_x86)

```sh
cd ./so_*/
./ndk-build
```
