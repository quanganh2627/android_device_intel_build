# droidboot image
ifeq ($(TARGET_USE_DROIDBOOT),true)
TARGET_DROIDBOOT_OUT := $(PRODUCT_OUT)/droidboot
TARGET_DROIDBOOT_ROOT_OUT := $(TARGET_DROIDBOOT_OUT)/root
DROIDBOOT_PATH := $(TOP)/bootable/droidboot

INSTALLED_DROIDBOOTIMAGE_TARGET := $(PRODUCT_OUT)/droidboot.img

droidboot_initrc := $(call get-specific-config-file ,droidboot.init.rc)
droidboot_kernel := $(INSTALLED_KERNEL_TARGET) # same as a non-recovery system
droidboot_ramdisk := $(PRODUCT_OUT)/ramdisk-droidboot.img
droidboot_build_prop := $(INSTALLED_BUILD_PROP_TARGET)
droidboot_binary := $(call intermediates-dir-for,EXECUTABLES,droidboot)/droidboot
droidboot_watchdogd := $(call intermediates-dir-for,EXECUTABLES,watchdogd)/watchdogd

# Look for output file. Build system before droidboot. Copy the files if they exist.
droidboot_modem_download_tool := $(call module-installed-files,cmfwdl-app)
droidboot_modem_proxy_tool := $(call module-installed-files,proxy-recovery)

droidboot_logcat := $(call intermediates-dir-for,EXECUTABLES,logcat)/logcat
droidboot_resources_common := $(DROIDBOOT_PATH)/res
droidboot_fstab: partition_files

droidboot_modules := \
	libc \
	libcutils \
	libdl \
	liblog \
	libm \
	libstdc++ \
	linker \
	mksh \
	systembinsh \
	toolbox \
	libdiskconfig \
	libext2fs \
	libext2_com_err \
	libext2_e2p \
	libext2_blkid \
	libext2_uuid \
	libext2_profile \
	libext4_utils \
	libsparse \
	libusbhost \
	libz \
	resize2fs \
	tune2fs \
	e2fsck \
	gzip \
	kexec \
	droidboot \

ifneq ($(call intel-target-need-intel-libraries),)
droidboot_modules += libimf libintlc libsvml
endif

droidboot_system_files := $(call module-installed-files,$(droidboot_modules))

# $(1): source base dir
# $(2): target base dir
define droidboot-copy-files
$(hide) $(foreach srcfile,$(droidboot_system_files), \
	destfile=$(patsubst $(1)/%,$(2)/%,$(srcfile)); \
	mkdir -p `dirname $$destfile`; \
	cp -fR $(srcfile) $$destfile; \
)
endef


INTERNAL_DROIDBOOTIMAGE_ARGS := \
	$(addprefix --second ,$(INSTALLED_2NDBOOTLOADER_TARGET)) \
	--kernel $(droidboot_kernel) \
	--ramdisk $(droidboot_ramdisk)

INTERNAL_DROIDBOOTIMAGE_ARGS += --product $(TARGET_DEVICE)
INTERNAL_DROIDBOOTIMAGE_ARGS += --type droidboot

# Assumes this has already been stripped
ifdef BOARD_KERNEL_CMDLINE
  INTERNAL_DROIDBOOTIMAGE_ARGS += --cmdline "$(BOARD_KERNEL_CMDLINE) $(BOARD_KERNEL_DROIDBOOT_EXTRA_CMDLINE)"
endif
ifdef BOARD_KERNEL_BASE
  INTERNAL_DROIDBOOTIMAGE_ARGS += --base $(BOARD_KERNEL_BASE)
endif
BOARD_KERNEL_PAGESIZE := $(strip $(BOARD_KERNEL_PAGESIZE))
ifdef BOARD_KERNEL_PAGESIZE
  INTERNAL_DROIDBOOTIMAGE_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
endif

$(INSTALLED_DROIDBOOTIMAGE_TARGET): $(MKBOOTFS) $(MKBOOTIMG) $(MINIGZIP) systemimg_gz\
		$(INSTALLED_RAMDISK_TARGET) \
		$(INSTALLED_BOOTIMAGE_TARGET) \
		$(droidboot_system_files) \
		$(droidboot_binary) \
		$(droidboot_watchdogd) \
		$(droidboot_initrc) $(droidboot_kernel) \
		$(droidboot_logcat) \
		$(droidboot_build_prop)
	@echo ----- Making droidboot image ------
	rm -rf $(TARGET_DROIDBOOT_OUT)
	mkdir -p $(TARGET_DROIDBOOT_OUT)
	mkdir -p $(TARGET_DROIDBOOT_ROOT_OUT)
	mkdir -p $(TARGET_DROIDBOOT_ROOT_OUT)/tmp
	mkdir -p $(TARGET_DROIDBOOT_ROOT_OUT)/system/etc
	mkdir -p $(TARGET_DROIDBOOT_ROOT_OUT)/system/bin
	mkdir -p $(TARGET_DROIDBOOT_ROOT_OUT)/mnt/sdcard
	echo Copying baseline ramdisk...
	cp -R $(TARGET_ROOT_OUT) $(TARGET_DROIDBOOT_OUT)
	rm $(TARGET_DROIDBOOT_ROOT_OUT)/init*.rc
	echo Modifying ramdisk contents...
	cp -f $(droidboot_initrc) $(TARGET_DROIDBOOT_ROOT_OUT)/init.rc
	if [ -f $(TARGET_DEVICE_DIR)/droidboot.init.$(TARGET_PRODUCT).rc ]; then \
	cp -f $(TARGET_DEVICE_DIR)/droidboot.init.$(TARGET_PRODUCT).rc $(TARGET_DROIDBOOT_ROOT_OUT); \
	fi
	cp -f $(droidboot_binary) $(TARGET_DROIDBOOT_ROOT_OUT)/system/bin/
	cp -f $(droidboot_watchdogd) $(TARGET_DROIDBOOT_ROOT_OUT)/system/bin/
	-cp -f $(droidboot_modem_download_tool) $(TARGET_DROIDBOOT_ROOT_OUT)/system/bin/ >/dev/null 2>&1
	-cp -f $(droidboot_modem_proxy_tool) $(TARGET_DROIDBOOT_ROOT_OUT)/sbin/proxy >/dev/null 2>&1
	cp -f $(droidboot_logcat) $(TARGET_DROIDBOOT_ROOT_OUT)/system/bin/logcat
	cp -rf $(droidboot_resources_common) $(TARGET_DROIDBOOT_ROOT_OUT)/
	$(MKPARTITIONFILE)
	cat $(INSTALLED_DEFAULT_PROP_TARGET) $(droidboot_build_prop) \
	        > $(TARGET_DROIDBOOT_ROOT_OUT)/default.prop
	$(hide) $(call droidboot-copy-files,$(TARGET_OUT),$(TARGET_DROIDBOOT_ROOT_OUT)/system/)
	$(MKBOOTFS) $(TARGET_DROIDBOOT_ROOT_OUT) | $(MINIGZIP) > $(droidboot_ramdisk)
	$(MKBOOTIMG) $(INTERNAL_DROIDBOOTIMAGE_ARGS) --output $@
	@echo ----- Made droidboot image -------- $@

else
INSTALLED_DROIDBOOTIMAGE_TARGET :=
endif

.PHONY: droidbootimage
droidbootimage: $(INSTALLED_DROIDBOOTIMAGE_TARGET)
