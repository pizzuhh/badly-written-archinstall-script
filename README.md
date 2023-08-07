# badly-written-archinstall-script
An archinstall script written in lua

(idk lua so any tips on how to write in are welcome)

# FaQ

Q: Why i decided to write it?

A: There's no reason at all. I was just bored xD

Q: The state of the script right now?

A: When you run the script you have to set up the partitions, don't worry it's easy with cfdisk, after that it'll format them and mount them. Next the script will pacstrap the system and generate fstab file

Q: When will the final version come?

A: Maybe this or the next month

# How do i use it?
Firstly make sure you have git and lua installed.
Run ``pacman-key --init`` and install git ``pacman -Sy git`` 

You should probably have lua installed but if you don't do ``pacman -S lua``

Next up clone the repo with ``git clone https://github.com/pizzuhh/badly-written-archinstall-script``, ``cd ./badly-written-archinstall-script`` and run it ``lua archinstall.lua``

#### More changes soon
