.PHONY: intel_prebuilts
$(foreach m, $(modules_to_install),\
	$(eval intel_prebuilts: $(strip $(ALL_MODULES.$(m).PREBUILT_MAKEFILE))))
intel_prebuilts:
	@echo did make following prebuilts Android.mk:
	@$(foreach m, $?,\
		echo "    " $(m);)
	@find $(TARGET_OUT_prebuilts) -name Android.mk -print -exec cat {} \;
