
MALI_LIB_PREBUILT=true
#build in hardware/amlogic/ddk
ifneq (,$(wildcard hardware/amlogic/ddk))
MALI_LIB_PREBUILT=false
endif
#build in hardware/arm/gpu/ddk
ifneq (,$(wildcard hardware/arm/gpu/ddk))
MALI_LIB_PREBUILT=false
endif
ifneq (,$(wildcard vendor/arm/t83x))
MALI_LIB_PREBUILT=false
endif
ifneq (,$(wildcard vendor/amlogic/meson_mali))
MALI_LIB_PREBUILT=false
endif
#already in hardware/arm/gpu/lib

ifeq ($(MALI_LIB_PREBUILT),true)
LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

TARGET:=$(GPU_TYPE)
TARGET?=mali400
ifeq ($(USING_MALI450), true)
TARGET=mali450
endif

TARGET:=$(TARGET)_ion
GPU_TARGET_PLATFORM ?= default_7a
ifeq ($(GPU_ARCH),midgard)
GPU_DRV_VERSION?=r11p0
else
GPU_DRV_VERSION?=r6p1
endif

$(info "the value of PLATFORM_SDK_VERSION is $(PLATFORM_SDK_VERSION)")
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 32 && echo OK),OK)
LOCAL_ANDROID_VERSION_NUM:=t-${GPU_DRV_VERSION}
else
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 31 && echo OK),OK)
LOCAL_ANDROID_VERSION_NUM:=s-${GPU_DRV_VERSION}
else
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 30 && echo OK),OK)
LOCAL_ANDROID_VERSION_NUM:=r-${GPU_DRV_VERSION}
else
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 29 && echo OK),OK)
LOCAL_ANDROID_VERSION_NUM:=q-${GPU_DRV_VERSION}
else
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 28 && echo OK),OK)
LOCAL_ANDROID_VERSION_NUM:=p-${GPU_DRV_VERSION}
else
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 26 && echo OK),OK)
LOCAL_ANDROID_VERSION_NUM:=o-${GPU_DRV_VERSION}
else
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 24 && echo OK),OK)
LOCAL_ANDROID_VERSION_NUM:=n-${GPU_DRV_VERSION}
else
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 23 && echo OK),OK)
LOCAL_ANDROID_VERSION_NUM:=m-${GPU_DRV_VERSION}
else
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 22 && echo OK),OK)
LOCAL_ANDROID_VERSION_NUM:=l-${GPU_DRV_VERSION}
else
LOCAL_ANDROID_VERSION_NUM:=k-${GPU_DRV_VERSION}
endif
endif
endif
endif
endif
endif
endif
endif
endif

ifneq ($(GPU_HW_VERSION),)
LOCAL_ANDROID_VERSION_NUM:=${LOCAL_ANDROID_VERSION_NUM}-$(GPU_HW_VERSION)
endif

ifeq ($(GRALLOC_USE_GRALLOC1_API),1)
LOCAL_ANDROID_VERSION_NUM:=${LOCAL_ANDROID_VERSION_NUM}gralloc1
endif

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 30 && echo OK),OK)
LOCAL_MODULE := libGLES_meson_mali
LOCAL_MODULE_STEM := libGLES_mali.so
else
LOCAL_MODULE := libGLES_mali
LOCAL_MODULE_SUFFIX := .so
endif
LOCAL_MULTILIB := both
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 26 && echo OK),OK)
LOCAL_MODULE_PATH    := $(TARGET_OUT_VENDOR)/egl
LOCAL_MODULE_PATH_32 := $(TARGET_OUT_VENDOR)/lib/egl
LOCAL_MODULE_PATH_64 := $(TARGET_OUT_VENDOR)/lib64/egl
else
LOCAL_MODULE_PATH    := $(TARGET_OUT_SHARED_LIBRARIES)/egl
LOCAL_MODULE_PATH_32 := $(TARGET_OUT)/lib/egl
LOCAL_MODULE_PATH_64 := $(TARGET_OUT)/lib64/egl
endif

ifeq ($(TARGET_2ND_ARCH),)
ifneq ($(ANDROID_BUILD_TYPE), 64)
LOCAL_SRC_FILES    	 := $(TARGET)/libGLES_mali_$(GPU_TARGET_PLATFORM)_32-$(LOCAL_ANDROID_VERSION_NUM).so
else
LOCAL_SRC_FILES_64	 := $(TARGET)/libGLES_mali_$(GPU_TARGET_PLATFORM)_64-$(LOCAL_ANDROID_VERSION_NUM).so
endif
else
LOCAL_SRC_FILES_32       := $(TARGET)/libGLES_mali_$(GPU_TARGET_PLATFORM)_32-$(LOCAL_ANDROID_VERSION_NUM).so
LOCAL_SRC_FILES_64	 := $(TARGET)/libGLES_mali_$(GPU_TARGET_PLATFORM)_64-$(LOCAL_ANDROID_VERSION_NUM).so
endif

#BOARD_INSTALL_VULKAN default is false
#It should defined in $(TARGET_PRODUCT).mk if Vulkan is needed.
$(info "the value of BOARD_INSTALL_VULKAN is $(BOARD_INSTALL_VULKAN)")
ifneq ($(BOARD_INSTALL_VULKAN),false)
$(info TARGET_PRODUCT is $(TARGET_PRODUCT))
LOCAL_POST_INSTALL_CMD = \
	if [ ! -d $(dir $(LOCAL_INSTALLED_MODULE))/../hw ]; then \
		mkdir -p $(dir $(LOCAL_INSTALLED_MODULE))/../hw; \
	fi;\
	cd $(dir $(LOCAL_INSTALLED_MODULE))/../hw;\
	pwd; \
	ln -sf ../egl/$(notdir $(LOCAL_INSTALLED_MODULE)) ./vulkan.amlogic.so;
endif

ifeq ($(BOARD_INSTALL_OPENCL),true)
#related to vulkan.amlogic.so
LOCAL_POST_INSTALL_CMD += \
	cd ..; \
	ln -sf egl/$(notdir $(LOCAL_INSTALLED_MODULE)) libOpenCL.so.1.1;\
	ln -sf libOpenCL.so.1.1 libOpenCL.so.1;\
	ln -sf libOpenCL.so.1 libOpenCL.so;
endif

LOCAL_SHARED_LIBRARIES := \
    android.hardware.graphics.common@1.0 \
    libcutils \
    liblog \
    libnativewindow \
    libz

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 30 && echo OK),OK)
LOCAL_SHARED_LIBRARIES += android.hardware.graphics.mapper@4.0 libc++ libc libcutils libdl libgralloctypes libhardware libhidlbase liblog libm libnativewindow libutils libz
endif
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -eq 31 && echo OK),OK)
LOCAL_SHARED_LIBRARIES += android.hardware.graphics.mapper@4.0 arm.graphics-V1-ndk_platform libc++ libc libcutils libdl libdmabufheap libgralloctypes libhardware libhidlbase liblog libm libnativewindow libutils libz
endif

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 32 && echo OK),OK)
LOCAL_SHARED_LIBRARIES += android.hardware.graphics.mapper@4.0 libc++ libc libcutils libdl libdmabufheap libgralloctypes libhardware libhidlbase liblog libm libnativewindow libutils libz
LOCAL_CHECK_ELF_FILES := false
endif

LOCAL_LICENSE_KINDS := SPDX-license-identifier-Apache-2.0 SPDX-license-identifier-FTL SPDX-license-identifier-GPL SPDX-license-identifier-LGPL-2.1 SPDX-license-identifier-MIT legacy_by_exception_only legacy_notice legacy_proprietary
LOCAL_LICENSE_CONDITIONS := by_exception_only notice restricted proprietary by_exception_only
LOCAL_NOTICE_FILE := $(LOCAL_PATH)/LICENSE

include $(BUILD_PREBUILT)

endif

ifeq ($(BOARD_INSTALL_SECURE_GLES),true)
include $(CLEAR_VARS)
LOCAL_MODULE := libSecure.so

LOCAL_MULTILIB := both
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 26 && echo OK),OK)
LOCAL_MODULE_PATH    := $(TARGET_OUT_VENDOR)
LOCAL_MODULE_PATH_32 := $(TARGET_OUT_VENDOR)/lib
LOCAL_MODULE_PATH_64 := $(TARGET_OUT_VENDOR)/lib64
else
LOCAL_MODULE_PATH    := $(TARGET_OUT_SHARED_LIBRARIES)
LOCAL_MODULE_PATH_32 := $(TARGET_OUT)/lib
LOCAL_MODULE_PATH_64 := $(TARGET_OUT)/lib64
endif

ifeq ($(TARGET_2ND_ARCH),)
ifneq ($(ANDROID_BUILD_TYPE), 64)
LOCAL_SRC_FILES    	 := $(TARGET)/libGLES_mali_$(GPU_TARGET_PLATFORM)_32-$(LOCAL_ANDROID_VERSION_NUM)-secure.so
else
LOCAL_SRC_FILES_64	 := $(TARGET)/libGLES_mali_$(GPU_TARGET_PLATFORM)_64-$(LOCAL_ANDROID_VERSION_NUM)-secure.so
endif
else
LOCAL_SRC_FILES_32       := $(TARGET)/libGLES_mali_$(GPU_TARGET_PLATFORM)_32-$(LOCAL_ANDROID_VERSION_NUM)-secure.so
LOCAL_SRC_FILES_64	 := $(TARGET)/libGLES_mali_$(GPU_TARGET_PLATFORM)_64-$(LOCAL_ANDROID_VERSION_NUM)-secure.so
endif
LOCAL_CHECK_ELF_FILES := false
LOCAL_LICENSE_KINDS := SPDX-license-identifier-Apache-2.0 SPDX-license-identifier-FTL SPDX-license-identifier-GPL SPDX-license-identifier-LGPL-2.1 SPDX-license-identifier-MIT legacy_by_exception_only legacy_notice legacy_proprietary
LOCAL_LICENSE_CONDITIONS := by_exception_only notice restricted proprietary by_exception_only
LOCAL_NOTICE_FILE := $(LOCAL_PATH)/LICENSE
include $(BUILD_PREBUILT)
endif

# compile libgpudataproducer.so
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 33 && echo OK),OK)
include $(CLEAR_VARS)
LOCAL_MODULE := libgpudataproducer
LOCAL_MODULE_STEM := libgpudataproducer.so
LOCAL_MULTILIB := both
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
LOCAL_MODULE_PATH    := $(TARGET_OUT_VENDOR_SHARED_LIBRARIES)
LOCAL_MODULE_PATH_32 := $(TARGET_OUT_VENDOR)/lib
LOCAL_MODULE_PATH_64 := $(TARGET_OUT_VENDOR)/lib64

ifeq ($(TARGET_2ND_ARCH),)
ifneq ($(ANDROID_BUILD_TYPE), 64)
LOCAL_SRC_FILES    	 := $(TARGET)/libgpudataproducer_$(GPU_TARGET_PLATFORM)_32-$(LOCAL_ANDROID_VERSION_NUM).so
else
ifneq ($(filter $(GPU_TYPE),valhall gondul),)
LOCAL_SRC_FILES_64	 := $(TARGET)/libgpudataproducer_$(GPU_TARGET_PLATFORM)_64-$(LOCAL_ANDROID_VERSION_NUM).so
endif
endif
else
LOCAL_SRC_FILES_32       := $(TARGET)/libgpudataproducer_$(GPU_TARGET_PLATFORM)_32-$(LOCAL_ANDROID_VERSION_NUM).so
ifneq ($(filter $(GPU_TYPE),valhall gondul),)
LOCAL_SRC_FILES_64	 := $(TARGET)/libgpudataproducer_$(GPU_TARGET_PLATFORM)_64-$(LOCAL_ANDROID_VERSION_NUM).so
endif
endif
LOCAL_CHECK_ELF_FILES := false
LOCAL_LICENSE_KINDS := SPDX-license-identifier-Apache-2.0 SPDX-license-identifier-FTL SPDX-license-identifier-GPL SPDX-license-identifier-LGPL-2.1 SPDX-license-identifier-MIT legacy_by_exception_only legacy_notice legacy_proprietary
LOCAL_LICENSE_CONDITIONS := by_exception_only notice restricted proprietary by_exception_only
LOCAL_NOTICE_FILE := $(LOCAL_PATH)/LICENSE
include $(BUILD_PREBUILT)
endif
