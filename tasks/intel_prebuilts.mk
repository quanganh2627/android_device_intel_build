ifneq ($(TARGET_OUT_prebuilts),)
intel_prebuilts_top_makefile := $(TARGET_OUT_prebuilts)/Android.mk
$(intel_prebuilts_top_makefile):
	@mkdir -p $(dir $@)
	@echo 'LOCAL_PATH := $$(call my-dir)' > $@
	@echo 'ifeq ($$(TARGET_ARCH),x86)' >> $@
	@echo 'include $$(shell find $$(LOCAL_PATH) -mindepth 2 -name "Android.mk")' >> $@
	@echo 'endif' >> $@
endif

.PHONY: intel_prebuilts
$(foreach m, $(modules_to_install),\
	$(eval intel_prebuilts: $(strip $(ALL_MODULES.$(m).PREBUILT_MAKEFILE))))
$(foreach m, $(INTEL_PREBUILTS_MAKEFILE),\
	$(eval intel_prebuilts: $(strip $(m))))
intel_prebuilts: $(intel_prebuilts_top_makefile)
	@$(if $(TARGET_OUT_prebuilts), \
		echo did make following prebuilts Android.mk: \
		$(foreach m, $?,\
			echo "    " $(m);) \
		find $(TARGET_OUT_prebuilts) -name Android.mk -print -exec cat {} \;)
