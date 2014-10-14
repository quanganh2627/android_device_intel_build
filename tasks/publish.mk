# This provides the 'publish' and 'publish_ci' makefile targets.
#
# PUBLISH target:
# 	NOTE: When using the 'publish' target you MUST also use the 'dist'
# 	target.  The 'dist' target is a special target and unfortunately we
# 	can't just depend on the 'dist' target :(
# 	   e.g. 'make dist publish'
# 	   e.g. 'make droid dist publish'
#
# 	DO NOT DO: 'make publish' as it will not work
#
# PUBLISH_CI target:
# 	The 'publish_ci' target may be called by itself as it has a dependency
# 	on the one file we need.
# 	   e.g. 'make publish_ci'

TARGET_PUBLISH_PATH ?= $(shell echo $(TARGET_PRODUCT) | tr '[:lower:]' '[:upper:]')
publish_dest := $(TOP)/pub/$(TARGET_PUBLISH_PATH)/$(TARGET_BUILD_VARIANT)/
publish_make_dir = $(if $(wildcard $1),,mkdir -p $1)

.PHONY: publish_mkdir_dest
publish_mkdir_dest:
	$(call publish_make_dir, $(dir $(publish_dest)))

# Are we doing an 'sdk' type lunch target
PUBLISH_SDK := $(strip $(filter sdk sdk_x86,$(TARGET_PRODUCT)))

ifndef PUBLISH_SDK

.PHONY: publish_flashfiles
ifdef INTEL_FACTORY_FLASHFILES_TARGET
publish_flashfiles: publish_mkdir_dest $(INTEL_FACTORY_FLASHFILES_TARGET)
	@$(ACP) $(INTEL_FACTORY_FLASHFILES_TARGET) $(publish_dest)
else
publish_flashfiles:
	@echo "Warning: Unable to fulfill publish_flashfiles makefile request"
endif

.PHONY: publish_liveimage
ifdef INTEL_LIVEIMAGE_TARGET
publish_liveimage: publish_mkdir_dest $(INTEL_LIVEIMAGE_TARGET)
	@$(ACP) $(INTEL_LIVEIMAGE_TARGET) $(publish_dest)
else
publish_liveimage:
	@echo "Warning: Unable to fulfill publish_liveimage makefile request"
endif

PUB_INTEL_PREBUILTS := $(TOP)/pub/$(TARGET_PUBLISH_PATH)/prebuilts.zip

EXTERNAL_CUSTOMER ?= "g"

INTEL_PREBUILTS_LIST := $(shell repo forall -g bsp-priv -a $(EXTERNAL_CUSTOMER)_external=bin -p -c echo 2> /dev/null)
INTEL_PREBUILTS_LIST := $(filter-out project,$(INTEL_PREBUILTS_LIST))
INTEL_PREBUILTS_LIST := $(addprefix prebuilts/intel/, $(subst /PRIVATE/,/prebuilts/$(REF_PRODUCT_NAME)/,$(INTEL_PREBUILTS_LIST)))
INTEL_PREBUILTS_LIST += prebuilts/intel/Android.mk

$(PUB_INTEL_PREBUILTS): generate_intel_prebuilts
	@echo "Publish prebuilts for external release"
	$(hide) rm -f $@
	$(hide) cd $(PRODUCT_OUT) && zip -r $(abspath $@) $(INTEL_PREBUILTS_LIST)

# publish external if buildbot set EXTERNAL_BINARIES env variable
# and only for userdebug
ifeq (userdebug,$(TARGET_BUILD_VARIANT))
ifeq ($(EXTERNAL_BINARIES),true)
publish_intel_prebuilts: publish_mkdir_dest $(PUB_INTEL_PREBUILTS)
endif
endif

.PHONY: publish_factoryscripts
ifdef FACTORY_SCRIPTS_PACKAGE_TARGET
publish_factoryscripts: publish_mkdir_dest $(FACTORY_SCRIPTS_PACKAGE_TARGET)
	@$(ACP) $(FACTORY_SCRIPTS_PACKAGE_TARGET) $(publish_dest)
else
publish_factoryscripts:
	@echo "Warning: Unable to fulfill publish_factoryscripts makefile request"
endif

.PHONY: publish_fastboot-usb
ifdef fastboot_usb_bin
publish_fastboot-usb: publish_mkdir_dest $(fastboot_usb_bin)
	@$(ACP) $(fastboot_usb_bin) $(publish_dest)
else
publish_fastboot-usb:
	@echo "Warning: Unable to fulfill publish_fastboot-usb makefile request"
endif

# BYT-M specific ini and shell files
PUBLISH_CI_BYTM_FILES := $(PRODUCT_OUT)/byt_m_crb-gpt.ini \
	$(PRODUCT_OUT)/byt_m_crb-flash-all.sh \
	$(PRODUCT_OUT)/byt_m_crb-flash-incremental.sh \
	$(PRODUCT_OUT)/byt_m_crb-flash-ci.sh

# To public BYT-M binaries
.PHONY: publish_ci_bytm
publish_ci_bytm: publish_factoryscripts publish_fastboot-usb
	$(if $(wildcard $(publish_dest)), \
	  $(foreach f,$(PUBLISH_CI_BYTM_FILES), \
	    $(if $(wildcard $(f)),$(ACP) $(f) $(publish_dest);,)),)

PUBLISH_CI_FILES := $(DIST_DIR)/fastboot $(DIST_DIR)/adb
.PHONY: publish_ci
publish_ci: publish_flashfiles publish_liveimage
	$(if $(wildcard $(publish_dest)), \
	  $(foreach f,$(PUBLISH_CI_FILES), \
	    $(if $(wildcard $(f)),$(ACP) $(f) $(publish_dest);,)),)


else # !PUBLISH_SDK
# Unfortunately INTERNAL_SDK_TARGET is always defined, so its existence does
# not indicate that we are building the SDK

.PHONY: publish_ci
publish_ci: publish_sdk_target


.PHONY: publish_sdk_target
publish_sdk_target: publish_mkdir_dest $(INTERNAL_SDK_TARGET)
	@$(ACP) $(INTERNAL_SDK_TARGET) $(publish_dest)


endif # !PUBLISH_SDK


# We need to make sure our 'publish' target depends on the other targets so
# that it will get done at the end.  Logic copied from build/core/distdir.mk
PUBLISH_GOALS := $(strip $(filter-out publish publish_ci,$(MAKECMDGOALS)))
PUBLISH_GOALS := $(strip $(filter-out $(INTERNAL_MODIFIER_TARGETS),$(PUBLISH_GOALS)))
ifeq (,$(PUBLISH_GOALS))
# The commandline was something like "make publish" or "make publish showcommands".
# Add a dependency on a real target.
PUBLISH_GOALS := $(DEFAULT_GOAL)
endif

.PHONY: publish
publish: publish_mkdir_dest $(PUBLISH_GOALS)
	@$(ACP) $(DIST_DIR)/* $(publish_dest)
