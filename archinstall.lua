function install()
	io.write("Pacstrap will install the base system! the default command will be: pacstrap -K /mnt linux linux-firmware base vim (if you want to install other packages enter the names here MAKE SURE THEY ARE IN CORE AND EXTRA REPOS! or type none to skip this): ")
	pkg = io.read()
	local command = "pacstrap -K /mnt linux linux-firmware base vim"
	if pkg ~= "none" then
		local full = string.format("%s %s", command, pkg)
		print(full)
		os.execute(full)
	else
		print(command)
		os.execute(command)
	end
	print("\n\n\n!!!FINISHED PACSTRAP-ING!!!\nGENERATING FSTAB\n\n\n")
	os.execute("genfstab -U /mnt >> /mnt/etc/fstab")
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
	print("1. Partition the disk\n2. Format and mount the paritions\n3. Pacstrap the system and generate fstab")
	local choice = io.read()
	if choice == "1" then
		os.execute("cfdisk")
		main()
	elseif choice == "2" then
		print("1. Default partitions (root and swap if you made)\n2. Advanced (for more partitions and more advanced users e.g. /home)")
		local par = io.read()
		if par == "1" then
			part()
			os.execute("sleep " .. tonumber(5))
			main()
		elseif par == "2" then
			os.exit(2)
		else
			print("Invalid option!")
		end
	elseif choice == "3" then
		install()
		os.execute("sleep " .. tonumber(10))
		main()

	else 
		print("Invalid option!")
	end


end
main()
