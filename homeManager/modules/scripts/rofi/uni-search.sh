#!/usr/bin/env bash
# grim -g "$(slurp -d)" - | aichat -f | rofi -dmenu -p ""


user_input=$(echo "" | rofi -dmenu -p " " -theme-str 'listview { enabled: false; }')
cflag=$(echo "$user_input"|grep -- "-c")
aflag=$(echo "$user_input"|grep -- "-a")
hflag=$(echo "$user_input"|grep -- "-h")
nflag=$(echo "$user_input"|grep -- "-n")
gflag=$(echo "$user_input"|grep -- "-g")
wflag=$(echo "$user_input"|grep -- "-w")
sflag=$(echo "$user_input"|grep -- "-s")
# URLflag=$(echo "$user_input"|grep -E "^http|\\.com|\\.ca|\\.org|\\.to|\\.io|\\.ai")

if [[ -n "$user_input" && -z "$cflag" && -z "$aflag" && -z "$hflag" && -z "$nflag" && -z "$gflag" && -z "$wflag" && -z "$URLflag" && -z "$sflag" ]]; then
  
  user_input=$(echo "$user_input"| aichat -r "systemhelp")
  cflag=$(echo "$user_input"|grep -- "-c")
  gflag=$(echo "$user_input"|grep -- "-g")
  wflag=$(echo "$user_input"|grep -- "-w")
  
fi


if [[ -n "$URLflag" ]]; then
  
  zen --new-tab "${user_input}"
  
elif [[ -n "$gflag" ]]; then

  user_input=$(echo "$user_input" |grep -- "-g" | awk -F"-g " '{print $2}')
  
  if [[ -n "$user_input" ]]; then
    # user_input=$(echo "$user_input"| aichat -r "grammerchecker")
    zen --new-tab "https://www.google.com/search?q=${user_input}"   

  fi

elif [[ -n "$cflag" ]]; then

  user_input=$(echo "$user_input" |grep -- "-c" | awk -F"-c " '{print $2}')
    
  if [[ -n "$user_input" ]]; then
    
    zen --new-tab "https://chat.openai.com/?q=${user_input}"
    # grim -g "$(slurp -d)" - | aichat -f | rofi -dmenu -p ""
     
  fi

elif [[ -n "$aflag" ]]; then

  user_input=$(echo "$user_input" |grep -- "-a" | awk -F"-a " '{print $2}')
    
  if [[ -n "$user_input" ]]; then
    
    zen --new-tab "https://9animetv.to/search?keyword=${user_input}"
  
  fi

elif [[ -n "$hflag" ]]; then

  user_input=$(echo "$user_input" |grep -- "-h" | awk -F"-h " '{print $2}')
    
  if [[ -n "$user_input" ]]; then
    
    zen --private-window "https://www.google.com/search?q=${user_input}"
  
  fi

elif [[ -n "$nflag" ]]; then

  user_input=$(echo "$user_input" |grep -- "-n" | awk -F"-n " '{print $2}')
    
  if [[ -n "$user_input" ]]; then
    
    zen --new-tab "https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=${user_input}"
  
  fi

elif [[ -n "$sflag" ]]; then

  user_input=$(echo "$user_input" |grep -- "-s" | awk -F"-s " '{print $2}')
    
  if [[ -n "$user_input" ]]; then

    echo "$user_input"
    # aichat -f "$user_input" | rofi -dmenu -p ""    
  
  fi


elif [[ -n "$wflag" ]]; then

  user_input=$(echo "$user_input" |grep -- "-w" | awk -F"-w " '{print $2}')
    
  if [[ -n "$user_input" ]]; then
    
    user_input=$(echo "$user_input"| aichat -r "route")
    zen --new-tab "${user_input}"
  
  fi

fi



