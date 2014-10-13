#!/usr/bin/env python
# Copyright (c) 2014, Intel Corporation.
# Author: Chouleur Sylvain <chouleur.sylvain@intel.com>
# Author: Falempe Jocelyn <jocelyn.falempe@intel.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.

import sys
import struct
import argparse
from io import BytesIO

# function to display user's help
def user_help():
	script_name = sys.argv[0]
	sys.stderr.write("""
--- That script generates a bootloader ---
 The inputs are:
	an ifwi file (--ifwi option)
	a droidboot image (--droidboot option)
	a splashscreen image (--splashscreen option)
 The output is the bootloader.img written to stdout.
 Usage example:
 %s --ifwi src_path/ifwi.bin --droidboot src_path/droidboot.img --splashscreen src_path/splashscreen.img --version 0201 > bootloader.img

 Example to unpack a bootloader:
 %s --unpack bootloader.img
""" % script_name)
	sys.exit(1)

#### elements in the header ####
reserved = 0
revision = 4
flag_flash = 1
bl_magic = 'BOOTLDR!'

def write_component(buffer, magic, flag):
	ret = ""
	ret += magic
	ret += struct.pack('<I', len(buffer))
	ret += struct.pack('<B', flag_flash)
	ret += struct.pack('<BBB', reserved, reserved, reserved)
	ret += buffer
	return ret

def unpack(bootloader):
	header_fmt = '<8sHBBI'
	header_size = struct.calcsize(header_fmt)
	magic, rev, checksum, _, _ = struct.unpack(header_fmt, bootloader[:header_size])
	if magic != bl_magic:
		raise Exception('Invalid image: Wrong magic')
	if rev != revision:
		raise Exception('Unsupported revision: %d'%rev)

	offset = header_size;
	while offset < len(bootloader):
		c_header_fmt = "<8sIBBBB"
		c_header_size = struct.calcsize(c_header_fmt)
		c_magic, size, flags, _, _ , _ = struct.unpack(c_header_fmt, bootloader[offset:offset + c_header_size])
		data = bootloader[offset + c_header_size: offset + c_header_size + size]
		offset += c_header_size + size
		id = 1

		if c_magic == "IFWI!!!!":
			f = open("ifwi_"+ id + ".bin", 'w')
			f.write(data)
			id +=1
			continue
		if c_magic == "DROIDBT!":
			f = open('droidboot.img', 'w')
			f.write(data)
			continue
		if c_magic == "SPLASHS!":
			f = open('splashscreen.img', 'w')
			f.write(data)
			continue
		if c_magic == "CAPSULE!":
			f = open('capsule.bin', 'w')
			f.write(data)
			continue
		if c_magic == "ESP!!!!!":
			f = open('esp.zip', 'w')
			f.write(data)
			continue

############ main ###############
def main():
	parser = argparse.ArgumentParser(description='Build bootloader image.')
	parser.add_argument('--ifwi', metavar='ifwi.bin', action='append',
			    help='IFWI filename')
	parser.add_argument('--droidboot', metavar='droidboot.img', type=file,
			    help='Droidboot filename')
	parser.add_argument('--splashscreen', metavar='splashscreen.img', type=file,
			    help='Splashscreen filename')
	parser.add_argument('--capsule', metavar='capsule.bin', type=file,
			    help='Capsule filename')
	parser.add_argument('--esp', metavar='esp.zip', type=file,
			    help='ESP update filename')
	parser.add_argument('--version', metavar='version',
			    help='bootloader image version')
	parser.add_argument('--unpack', metavar='bootloader.img', type=file,
			    help='Bootloader image')
	args = parser.parse_args()

	if (not args.unpack == None):
		buf = args.unpack.read()
		unpack(buf)
		return

	out = ""
	out += bl_magic

	if (not args.version == None):
		version_major = int(args.version[0:2])
		version_minor = int(args.version[2:4])
	else:
		version_major = 99
		version_minor = 99
	out += struct.pack('<HBBI', revision, version_major, version_minor, reserved)

	if (not args.ifwi == None):
		for ifwi in args.ifwi:
			f = open(ifwi)
			buf = f.read()
			out += write_component(buf, 'IFWI!!!!', flag_flash)
			f.close
	if (not args.droidboot == None):
		buf = args.droidboot.read()
		out += write_component(buf, 'DROIDBT!', flag_flash)
	if (not args.splashscreen == None):
		buf = args.splashscreen.read()
		out += write_component(buf, 'SPLASHS!', flag_flash)
	if (not args.capsule == None):
		buf = args.capsule.read()
		out += write_component(buf, 'CAPSULE!', flag_flash)
	if (not args.esp == None):
		buf = args.esp.read()
		out += write_component(buf, 'ESP!!!!!', flag_flash)

	sys.stdout.write(out)
if __name__ == '__main__':
	main()
# End the program
