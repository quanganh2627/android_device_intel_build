ifeq ($(TARGET_KERNEL_SOURCE_IS_PRESENT),true)
# Rules to build the kernel
include $(COMMON_PATH)/AndroidKernel.mk
endif

# Additional rules for ifwi
# $(1) is the prefix of the module name, $(2) is source file
# $(3) is type ( dediprog, capsule, stage2 )

define ifwi_prebuild

include $(CLEAR_VARS)
LOCAL_MODULE := $(1)_$(3)
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES := $(2)
LOCAL_MODULE_STEM := $(2)
LOCAL_MODULE_PATH := $(PRODUCT_OUT)/ifwi/$(1)/$(3)
include $(BUILD_PREBUILT)

endef

