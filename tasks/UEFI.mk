INTERNAL_ESPIMAGE_FILES := $(filter $(TARGET_ROOT_OUT)/esp/%, \
    $(ALL_PREBUILT) \
    $(ALL_COPIED_HEADERS) \
    $(ALL_GENERATED_SOURCES) \
    $(ALL_DEFAULT_INSTALLED_MODULES))

BUILD_ESPIMAGE_DIR := $(PRODUCT_OUT)/esp

BIOS_CAPSULE_INPUT_FILE := $(FW_INGREDIENTS_PATHS)/capsule.bin
BIOS_CAPSULE_OUTPUT_FILE := BiosUpdate.fv

$(BUILD_ESPIMAGE_DIR):
	$(hide) mkdir -p $(BUILD_ESPIMAGE_DIR)

ifeq ($(TARGET_ARCH),x86)
    EFI_ARCH := ia32
endif
ifeq ($(TARGET_ARCH),x86-64)
    EFI_ARCH := x86_64
endif

EFILINUX_MODULE := efilinux-$(TARGET_BUILD_VARIANT)

$(INSTALLED_ESPIMAGE_TARGET): $(BUILD_ESPIMAGE_DIR) $(EFILINUX_MODULE) warmdump | $(HOST_OUT_EXECUTABLES)/mcopy $(HOST_OUT_EXECUTABLES)/mkdosfs
	$(call pretty,"Target ESP image: $@")
	$(hide) mkdir -p $(PRODUCT_OUT)/esp/EFI/BOOT $(PRODUCT_OUT)/esp/EFI/Intel $(PRODUCT_OUT)/esp/EFI/Intel/Data
	$(hide) $(ACP) $(PRODUCT_OUT)/$(EFILINUX_MODULE).efi $(PRODUCT_OUT)/esp/EFI/BOOT/boot$(EFI_ARCH).efi
	$(hide) $(ACP) $(PRODUCT_OUT)/$(EFILINUX_MODULE).efi $(PRODUCT_OUT)/esp/EFI/Intel/efilinux.efi
	$(hide) $(ACP) $(PRODUCT_OUT)/warmdump.efi $(PRODUCT_OUT)/esp/EFI/Intel/

ifeq ($(BOARD_HAS_CAPSULE),true)
ifneq (,$(wildcard $(BIOS_CAPSULE_INPUT_FILE)))
	$(hide) $(ACP) $(BIOS_CAPSULE_INPUT_FILE) $(PRODUCT_OUT)/esp/$(BIOS_CAPSULE_OUTPUT_FILE)
else
	$(hide) echo "$(BIOS_CAPSULE_INPUT_FILE) file doesn't exist, not included in $(INSTALLED_ESPIMAGE_TARGET)"
endif
endif
	$(hide) vendor/intel/support/make_vfatfs "ESP" \
		$(INSTALLED_ESPIMAGE_TARGET) \
		$(shell python -c 'import json; print json.load(open("'$(PART_MOUNT_OVERRIDE_FILE)'"))["partitions"]["ESP"]["size"]') \
		$(PRODUCT_OUT)/esp

espimage: $(INSTALLED_ESPIMAGE_TARGET)
