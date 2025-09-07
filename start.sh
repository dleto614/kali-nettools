#!/bin/bash

service dbus start

# TODO: write a service so that it can handle if NetworkManager crashes.
NetworkManager & # Apparently we can't use service for this pos software

/bin/bash 