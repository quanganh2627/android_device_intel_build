INC_OTA_PACKAGE := $(OUT)/inc-ota.zip

# Create an incremental OTA package based on the TFP in out/dist/

$(INC_OTA_PACKAGE): $(BUILT_TARGET_FILES_PACKAGE) $(DISTTOOLS)
	@echo "Package Incremental OTA: $@"
	$(hide) ./build/tools/releasetools/ota_from_target_files -v \
	   -p $(HOST_OUT) \
	   -k $(DEFAULT_KEY_CERT_PAIR) \
           -i out/dist/$(TARGET_PRODUCT)-target_files-$(FILE_NAME_TAG).zip \
	   $(BUILT_TARGET_FILES_PACKAGE) $@

.PHONY: incotapackage
incotapackage: $(INC_OTA_PACKAGE)

