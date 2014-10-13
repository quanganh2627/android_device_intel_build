# Generate the bootloader image
ifeq ($(TARGET_USE_BOOTLOADER),true)
INSTALLED_BOOTLOADERIMAGE_TARGET := $(PRODUCT_OUT)/bootloader.img

ifeq ($(TARGET_BIOS_TYPE),"uefi")
BOOTLOADER_ESP := --esp $(ESPUPDATE_ZIP_TARGET)
ifneq (,$(INSTALLED_CAPSULE_TARGET))
BOOTLOADER_CAPSULE := --capsule $(INSTALLED_CAPSULE_TARGET)
endif
endif

$(INSTALLED_BOOTLOADERIMAGE_TARGET): firmware $(INSTALLED_DROIDBOOTIMAGE_TARGET) $(INSTALLED_CAPSULE_TARGET) $(ESPUPDATE_ZIP_TARGET)
ifeq ($(TARGET_BIOS_TYPE),"iafw")
	$(hide) $(foreach ifwi, $(shell find $(PRODUCT_OUT)/ifwi -maxdepth 2 -name "ifwi*.bin"), $(eval BOOTLOADER_IFWI_FILES += --ifwi $(ifwi)))
endif
	@echo ----- Making bootloader image ------
	$(hide) python vendor/intel/build/tools/mkbootloader.py --droidboot $(INSTALLED_DROIDBOOTIMAGE_TARGET) $(BOOTLOADER_CAPSULE) $(BOOTLOADER_ESP) $(BOOTLOADER_IFWI_FILES) > $@
endif

.PHONY: bootloaderimage
bootloaderimage: $(INSTALLED_BOOTLOADERIMAGE_TARGET)
