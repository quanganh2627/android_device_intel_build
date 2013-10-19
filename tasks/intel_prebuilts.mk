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
$(foreach m, $(modules_to_install),\
	$(eval intel_prebuilts: $(strip $(ALL_MODULES.$(m).PREBUILT_MAKEFILE))) \
)

# $(modules_to_install) does not include LOCAL_SHARED_LIBRARIES etc. which have
# explicit dependencies in the build recipes.
#
# Get installed files from TARGET_DEPENDENCIES_ON_SHARED_LIBRARIES.
#
# TODO: Host? (HOST_DEPEDENCIES_ON_SHARED_LIBRARIES)
# 		LOCAL_STATIC_LIBRARIES?
# 		LOCAL_JNI_SHARED_LIBRARIES? (list not saved? see dist-for-goals?)
# 		LOCAL_*JAVA_*LIBRARIES?

# Find the module names for the libraries needed by $(modules_to_install)
# TARGET_DEPENDENCIES_ON_SHARED_LIBRARIES holds values like:
# 		<module name>:<module installed file>:<lib>,<lib>,...
_ext_lib_deps := $(sort \
	$(foreach m, $(modules_to_install),\
		$(foreach line,$(TARGET_DEPENDENCIES_ON_SHARED_LIBRARIES), \
			$(if $(findstring :$(m):,$(line)), \
				$(eval d_list := $(lastword $(subst :,$(space),$(line)))) \
				$(subst $(comma),$(space),$(d_list)) \
			) \
		) \
	) \
)

# NOTE: function from build/core/tasks/vendor_module_check.mk
# Expand the target modules installed via LOCAL_SHARED_LIBRARIES
# $(1): the list of modules to expand.
define ext-expand-required-shared-libraries
$(eval _ext_new_modules := $(filter $(addsuffix :%,$(1)),$(TARGET_DEPENDENCIES_ON_SHARED_LIBRARIES)))\
$(eval _ext_new_modules := $(foreach p,$(_ext_new_modules),$(word 3,$(subst :,$(space),$(p)))))\
$(eval _ext_new_modules := $(sort $(subst $(comma),$(space),$(_ext_new_modules))))\
$(eval _ext_new_modules := $(filter-out $(_ext_lib_deps),$(_ext_new_modules)))\
$(if $(_ext_new_modules),$(eval _ext_lib_deps += $(_ext_new_modules))\
  $(call ext-expand-required-shared-libraries,$(_ext_new_modules)))
endef

# Find depending libraries recursively
$(call ext-expand-required-shared-libraries,$(_ext_lib_deps))

# intel_prebuilts depends on the prebuilt makefiles for the libraries found
$(foreach f,$(call module-installed-files, $(_ext_lib_deps)), \
	$(eval intel_prebuilts: $(strip $(ALL_MODULES.$(f).PREBUILT_MAKEFILE))) \
)

$(foreach m, $(INTEL_PREBUILTS_MAKEFILE),\
	$(eval intel_prebuilts: $(strip $(m))))
intel_prebuilts: $(intel_prebuilts_top_makefile)
	@$(if $(TARGET_OUT_prebuilts), \
		echo did make following prebuilts Android.mk: \
		$(foreach m, $?,\
			echo "    " $(m);) \
		find $(TARGET_OUT_prebuilts) -name Android.mk -print -exec cat {} \;)
