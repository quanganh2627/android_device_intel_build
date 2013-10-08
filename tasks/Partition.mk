DEFAULT_PARTITION := $(TOP)/device/intel/common/storage/default_partition.json
DEFAULT_MOUNT := $(TOP)/device/intel/common/storage/default_mount.json
PART_MOUNT_OVERRIDE_FILE := $(call get-specific-config-file ,storage/part_mount_override.json)
ifeq ($(BIGCORE_USB_INSTALLER),true)
PART_MOUNT_OVERRIDE_FILE := $(call get-specific-config-file ,storage/part_mount_override_usbboot.json)
endif
PART_MOUNT_OVERRIDE_FILES := $(call get-all-config-files ,storage/part_mount_override.json)
PART_MOUNT_OUT := $(PRODUCT_OUT)

MKPARTITIONFILE:= \
	$(TOP)/vendor/intel/support/partition.py \
	$(DEFAULT_PARTITION) \
	$(DEFAULT_MOUNT) \
	$(PART_MOUNT_OVERRIDE_FILE) \
	"$(PART_MOUNT_OUT)" \
	"$(TARGET_DEVICE)"

# partition table for fastboot os
$(PRODUCT_OUT)/partition.tbl: $(DEFAULT_PARTITION) $(DEFAULT_MOUNT) $(PART_MOUNT_OVERRIDE_FILES)
	$(hide)mkdir -p $(dir $@)
	PART_MOUNT_OUT_FILE=$@	$(MKPARTITIONFILE)

# android main fstab
$(PRODUCT_OUT)/root/fstab.$(TARGET_DEVICE): $(DEFAULT_PARTITION) $(DEFAULT_MOUNT) $(PART_MOUNT_OVERRIDE_FILES)
	$(hide)mkdir -p $(dir $@)
	PART_MOUNT_OUT_FILE=$@	$(MKPARTITIONFILE)

# android recovery fstab
$(PRODUCT_OUT)/system/etc/recovery.fstab: $(DEFAULT_PARTITION) $(DEFAULT_MOUNT) $(PART_MOUNT_OVERRIDE_FILES)
	$(hide)mkdir -p $(dir $@)
	PART_MOUNT_OUT_FILE=$@	$(MKPARTITIONFILE)

# android charger fstab
$(PRODUCT_OUT)/root/fstab.charger.$(TARGET_DEVICE): $(DEFAULT_PARTITION) $(DEFAULT_MOUNT) $(PART_MOUNT_OVERRIDE_FILES)
	$(hide)mkdir -p $(dir $@)
	PART_MOUNT_OUT_FILE=$@	$(MKPARTITIONFILE)

$(BUILT_RAMDISK_TARGET): \
	$(PRODUCT_OUT)/root/fstab.$(TARGET_DEVICE) \
	$(PRODUCT_OUT)/root/fstab.charger.$(TARGET_DEVICE) \
	$(PRODUCT_OUT)/system/etc/recovery.fstab

blank_flashfiles: $(PRODUCT_OUT)/partition.tbl
