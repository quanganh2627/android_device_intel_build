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
# $(modules_to_install) is a list of installed files *for the target*.
# It includes all the modules added with "PRODUCT_PACKAGES +=" and depending
# packages through LOCAL_REQUIRED_MODULES.
#
# Unfortunately, other required modules (LOCAL_SHARED_LIBRARIES etc.) are set
# with explicit dependencies in the build recipes for $(modules_to_install).
#
# /!\ Check on TARGET_DEPENDENCIES_ON_SHARED_LIBRARIES is not recursive
# /!\ => This will only work for level-1 dependencies
#
# TODO: Host? (HOST_DEPEDENCIES_ON_SHARED_LIBRARIES)
# 		LOCAL_STATIC_LIBRARIES?
# 		LOCAL_JNI_SHARED_LIBRARIES? (list not saved? see dist-for-goals?)
# 		LOCAL_*JAVA_*LIBRARIES?
$(foreach m, $(modules_to_install),\
	$(eval intel_prebuilts: $(strip $(ALL_MODULES.$(m).PREBUILT_MAKEFILE))) \
	\
	$(eval ### "Check dependencies on shared libraries") \
	$(foreach line,$(TARGET_DEPENDENCIES_ON_SHARED_LIBRARIES), \
		$(if $(findstring :$(m):,$(line)), \
			$(eval d_list := $(lastword $(subst :,$(space),$(line)))) \
			$(eval d_mods := $(subst $(comma),$(space),$(d_list))) \
			$(foreach d, $(d_mods), \
				$(foreach _installed, $(ALL_MODULES.$(d).INSTALLED), \
					$(eval intel_prebuilts: $(strip $(ALL_MODULES.$(_installed).PREBUILT_MAKEFILE))) \
				) \
			) \
		) \
	) \
)
$(foreach m, $(INTEL_PREBUILTS_MAKEFILE),\
	$(eval intel_prebuilts: $(strip $(m))))
intel_prebuilts: $(intel_prebuilts_top_makefile)
	@$(if $(TARGET_OUT_prebuilts), \
		echo did make following prebuilts Android.mk: \
		$(foreach m, $?,\
			echo "    " $(m);) \
		find $(TARGET_OUT_prebuilts) -name Android.mk -print -exec cat {} \;)
