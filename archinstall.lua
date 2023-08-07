function DE()
	print("THEY WONT BE CONFIGURED!\n1. GNOME\n2. KDE\nmore soon!")
	local choice = io.read()
	if choice == "1" then
		os.execute("pacman -S gnome xorg xorg-server")
		os.execute("systemctl enable gdm.service")
	elseif choice == "2" then
		os.execute("pacman -S xorg plasma plasma-wayland-session kde-applications")
		os.execute("systemctl enable sddm.service")
	else
		print("Invalid option")
		desktop()
	end
	
end

function setup_grub()
	print("Do you even want to install GRUB? If you don't want to install grub it'll make this system unbootable until you add it to your current bootloader (if you dualboot)[y/n]")
	local yes_no = io.read()
	if yes_no == "y" then
		--installing grub

		print("pacman -S grub os-prober")
		os.execute("pacman -S grub os-prober")
		io.write("Where are we installing grub? (should be on the disk you are installing the system, example /dev/sda): ")
		local disk = io.read()
		os.execute(string.format("grub-install --target=i386-pc %s", disk))
		os.execute("grub-mkconfig -o /boot/grub/grub.cfg")
	else 
		print("You can always install grub or other bootloader later")
		os.execute("sleep 5")
		chroot_setup()
	
	end
end


function usr_setup()
	-- user setup
	io.write("User name: ")
	local usr = io.read()

	os.execute("echo \"%wheel ALL=(ALL:ALL) ALL\" >> /etc/sudoers")
	os.execute(string.format("useradd -m %s", usr))
	os.execute(string.format("usermod -aG wheel,audio,video,storage %s", usr))
	
	print("Setting up password for your user\n\n")
	os.execute(string.format("passwd %s", usr))
	print("Setting up password for root user\n\n")
	os.execute("passwd")
	
	-- hostname
	io.write("Enter hostname (example arch): ")
	local hostname = io.read()
	os.execute(string.format("echo %s >> /etc/hostname", hostname))
	
	-- locale; setting up the default one for now
	local locale = "en_US.UTF-8"
	os.execute(string.format("echo %s >> /etc/locale.gen", locale))
	os.execute(string.format("echo LANG=%s >> /etc/locale.conf", locale))
	os.execute(string.format("export LANG=%s", locale))


end


function chroot_setup()
	os.execute("clear")

	print("1. Install few packages(networkmanager, sudo, base-devel)\n2. Set-up loacels, users, hostname and sudo\n3. Install boot manager (GRUB)\n4. Choose desktop\n5. Exit chroot")
	local choice = io.read()
	if choice == "1" then
		os.execute("pacman -S networkmanager sudo base-devel")
		chroot_setup()
	elseif choice == "2" then
		usr_setup()
		chroot_setup()
	elseif choice == "3" then
		setup_grub()
		chroot_setup()
	elseif choice == "4" then
		DE()
		chroot_setup()
	elseif choice == "5" then
		print("To exit chroot simply type \"exit\"")
		os.exit(0)
	else
		print("Invalid option")
		chroot_setup()

	end

end


function install()
	io.write("Pacstrap will install the base system! the default command will be: \"pacstrap -K /mnt linux linux-firmware base vim lua\" (if you want to install other packages enter the names here MAKE SURE THEY ARE IN CORE AND EXTRA REPOS! or type none to skip this): ")
	pkg = io.read()
	local command = "pacstrap -K /mnt linux linux-firmware base vim lua git"
	if pkg ~= "none" then
		local full = string.format("%s %s", command, pkg)
		print(full)
		local ret = os.execute(full)
		if ret == nil then
			print("pacstrap faialed?")
		end
	else
		print(command)
		local ret = os.execute(command)
		if ret == nil then
			print("pacstrap faialed?")
		end
	end
	print("\n\n\n!!!FINISHED PACSTRAP-ING!!!\nGENERATING FSTAB\n\n\n")
	print("genfstab -U /mnt > /mnt/etc/fstab")
	local fstab = os.execute("genfstab -U /mnt > /mnt/etc/fstab")
	os.execute("cat /mnt/etc/fstab")
	if fstab == nil then
		print("fstab failed?")
	end
end


function part()
	io.write("*Enter root partition (example /dev/sda1): ")
	local root = io.read()
	io.write("Enter swap partition (example /dev/sda2;; enter none if you don't have): ")
	local swap = io.read()
	print("DEFAULT FILE SYSTEM IS EXT4!")
	
	-- root
	os.execute(string.format("mkfs.ext4 %s", root))
	os.execute(string.format("mount %s /mnt", root))
	-- swap
	if swap ~= "none" then
	os.execute(string.format("mkswap %s", swap))
	os.execute(string.format("swapon %s", swap))
	end
end

function main()
	os.execute("clear")
	print("1. Partition the disk\n2. Format and mount the paritions\n3. Pacstrap the system and generate fstab\n4. CHROOT\n5.CHROOT-SETUP(execute only when you are in chroot environment!)\n6. Unmount and reboot")
	local choice = io.read()
	if choice == "1" then
		os.execute("cfdisk")
		main()
	elseif choice == "2" then
		print("1. Default partitions (root and swap if you made)\n2. Advanced (for more partitions and more advanced users e.g. /home)")
		local par = io.read()
		if par == "1" then
			part()
			os.execute("sleep 5")
			main()
		elseif par == "2" then
			os.exit(2)
		else
			print("Invalid option!")
		end
	elseif choice == "3" then
		install()
		os.execute("sleep 10")
		main()
	
	elseif choice == "4" then
		print("This file will be copied to the root of the choorted enviroment (simply do cd /) and you'll be able to execute it!\nContinue from option 5 when you execute it in the chrooted enviroment!")
		os.execute("sleep 10")
		os.execute("cp ./archinstall.lua /mnt/archinstall.lua")
		os.execute("arch-chroot /mnt")

	elseif choice == "5" then
		chroot_setup()
		main()
	elseif choice == "6" then
		os.execute("umount -R /mnt")
		os.execute("reboot")
	else 
		print("Invalid option!")
		main()
	end


end
main()
