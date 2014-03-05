ifeq ($(TARGET_KERNEL_SOURCE_IS_PRESENT),true)
# Rules to build the kernel
include $(COMMON_PATH)/AndroidKernel.mk
endif

