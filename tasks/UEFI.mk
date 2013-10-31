INTERNAL_ESPIMAGE_FILES := $(filter $(TARGET_ROOT_OUT)/esp/%, \
    $(ALL_PREBUILT) \
    $(ALL_COPIED_HEADERS) \
    $(ALL_GENERATED_SOURCES) \
    $(ALL_DEFAULT_INSTALLED_MODULES))

BUILT_ESPIMAGE_TARGET := $(PRODUCT_OUT)/esp.img
BUILD_ESPIMAGE_DIR := $(PRODUCT_OUT)/esp

INSTALLED_ESPIMAGE_TARGET := $(BUILT_ESPIMAGE_TARGET)

$(BUILD_ESPIMAGE_DIR):
	$(hide) mkdir -p $(BUILD_ESPIMAGE_DIR)

ifeq ($(TARGET_ARCH),x86)
    EFI_ARCH := ia32
endif
ifeq ($(TARGET_ARCH),x86-64)
    EFI_ARCH := x86_64
endif

$(INSTALLED_ESPIMAGE_TARGET): $(BUILD_ESPIMAGE_DIR) efilinux | $(HOST_OUT_EXECUTABLES)/mcopy
	$(call pretty,"Target ESP image: $@")
	$(hide) mkdir -p $(PRODUCT_OUT)/esp/EFI/BOOT $(PRODUCT_OUT)/esp/EFI/Intel
	$(hide) ln -sf ../../../efilinux.efi $(PRODUCT_OUT)/esp/EFI/BOOT/boot$(EFI_ARCH).efi
	$(hide) ln -sf ../../../efilinux.efi $(PRODUCT_OUT)/esp/EFI/Intel/
	$(hide) vendor/intel/support/make_vfatfs "ESP" \
		$(BUILT_ESPIMAGE_TARGET) \
		$(shell python -c 'import json; print json.load(open("'$(PART_MOUNT_OVERRIDE_FILE)'"))["partitions"]["ESP"]["size"]') \
		$(PRODUCT_OUT)/esp

espimage: $(INSTALLED_ESPIMAGE_TARGET)
