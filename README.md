# Kali Net Tools Docker Container:

## Introduction:

This idea came from wanting to use eaphammer without having to boot up a kali vm or live boot into kali, but I already plan on adding other tools to this docker container such as netexec to maybe create a more complete network and wifi docker container.

I do like eaphammer as a tool, but don't like the limited distros and the lazy installation instructions for non supported distros (like ffs... just provide a way to install via pipx or poetry or at least a way to install everything in a script that sets everything up in a venv or whatever.)

To install you have to run:

```bash
./scripts/build-docker.sh
```

This will build the docker container and install everything that we need.

Afterwards, if you want to start the docker and interact with it manually or something, you can run:

```bash
./scripts/start-docker.sh
sudo docker ps # To find the docker ID
sudo docker exec -it CONTAINER_ID /bin/bash
```

The kali docker container is a very bare bones container, so don't expect it to be like in the live usb or vm, but this also makes it a perfect platform to build and do what I want to do (I love the repos for stuff like this).

To generate certs, you can use the `generate-certs.sh` script.

Usage:

```bash
Usage: ./scripts/generate-certs.sh [ -c COUNTRY CODE ]
                  [ -s STATE OR PROVINCE ]
                  [ -l CITY ]
                  [ -o ORGANIZATION ]
                  [ -u ORGANIZATIONAL UNIT ]
                  [ -n DOMAIN NAME ]
                  [ -f FOLDER TO STORE CERTS]
                  [ -h HELP ]
```

Everything but folder are required parameters. This will generate all the certs you need and final output is the pem file which combines the keys together in a single file which is what is used in the other script to import the cert.

Example usage:

```bash
./scripts/generate-certs.sh -c US -s OH -l Mars \
                                                -o "Ohio State University" \
                                                -u "Hummajn Resources" \
                                                -n osu.edu/ \
                                                -f ohio-uni-test
```

---

To run commands from the docker container, I have written this piece of sh- I mean shell script called `run-commands.sh` which lets you start and stop the docker container, import cert via specifying cert you created, run hostapd wpa-eap thingie with essid, channel, interface, etc... you know all the things to make it useful?

Usage:

```bash
Usage: ./scripts/run-commands.sh [ -c CERT ]
                [ -o OUTPUT FILE ]
                [ -e ESSID ]
                [ -C CHANNEL ]
                [ -i INTERFACE ]
                [ -a AUTH ]
                [ --start-docker START DOCKER CONTAINER ]
                [ --stop-docker STOP DOCKER CONTAINER ]
                [ --creds SHOW CREDENTIALS ]
                [ --extract-hostapd EXTRACT EAP FROM EAPHAMMER HOSTAPD LOG ]
                [ -h HELP ]
```

From the wikipedia, the command to start a rogue ap is:

```bash
./eaphammer --bssid 1C:7E:E5:97:79:B1 \
 --essid Example \
 --channel 2 \
 --interface wlan0 \
 --auth wpa-eap \
 --creds
```

So in my script:

```bash
./scripts/run-commands.sh -e Broccoli29 -C 1 -i wlan1 -a wpa-eap --creds
```

These arguments would then be passed to the container to run a similar command above. The exact command from my script:

```bash
sudo docker exec -it "$CONTAINER_ID" ./eaphammer/eaphammer \
		--essid "$ESSID" \
		--channel "$CHANNEL" \
		--interface "$INTERFACE" \
		--auth "$AUTH" \
		--creds
```

You can combine the various actions together. Such as -c aka the cert flag:

```bash
./scripts/run-commands.sh -e Broccoli29 \
                        -C 1 -i wlan1 \
                        -a wpa-eap \
                        --creds -c certs/generated/ohio-uni-test/cert.pem 
```

This would import the cert specified before starting the AP.

You can also extract hostapd from the log file and convert it to json for easy parsing since the logfile is not in a good parsable format for scripts and such:

```bash
 ./scripts/run-commands.sh --extract-hostapd -o output.json
```

This can be combined with other commands as well, but I mostly used it as part of `--stop-docker` command flag:

```bash
 ./scripts/run-commands.sh --stop-docker --extract-hostapd -o output.json
```

---

# Conclusion:

I built this with the possibility of adding more stuff to it since I have a bit more planned, but my current reason for doing this is now complete so I'm going to be busy with other projects and will come back to this later.

## Future plans:

- Write scripts for netexec.
- Add to my scripts more eaphammer features.
- Figure out which tools I want to add. Can probably add some of the wifi tools, but most defintely network tools.

---

# References:

(Would've taken too long to explain above)

More information on WPA-EAP specifically credential stealing to gain entrance via an evil twin:

https://shuciran.github.io/posts/Attacking-WPA-Enterprise/

https://github.com/s0lst1c3/s0lst1c3.github.io/blob/master/workshops/advanced-wireless-attacks/ii-attacking-and-gaining-entry-to-wpa2-eap-wireless-networks.md

https://kalilinuxtutorials.com/eaphammer-targeted-evil-twin-attacks-against-wpa2-enterprise-networks/

https://wifi-fu.com/2025/02/07/a-look-at-wpa2-enterprise/

https://thr0cut.github.io/research/wifi-penetration-testing/

The original tool is hostapd-wpe which I think eaphammer might use a bit under the hood, but can't confirm 100%.

References to that tool:

https://www.kali.org/tools/hostapd-wpe/

https://github.com/OpenSecurityResearch/hostapd-wpe

https://warroom.rsmus.com/weaponizing-hostapd-wpe/

For more informatin on EAP, here are a few references:

https://www.techtarget.com/searchsecurity/definition/Extensible-Authentication-Protocol-EAP

https://thisvsthat.io/wpa-eap-vs-wpa2-eap

https://community.fortinet.com/t5/FortiAP/Technical-Tip-Understanding-WPA2-Enterprise-EAP-PEAP-packet/ta-p/366542

There is a lot on this topic and I really don't want to write about this in my README since it would take way too long.

