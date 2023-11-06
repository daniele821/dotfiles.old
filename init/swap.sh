#!/bin/bash

while ! sudo sway -y; do
    color "1;31" "installation of utilities failed!"
done
