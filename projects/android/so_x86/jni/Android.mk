LOCAL_PATH:= $(call my-dir)

# build x86 version
include $(CLEAR_VARS)
include $(LOCAL_PATH)/FlashRuntimeExtensions86.mk
include $(LOCAL_PATH)/libjs_static86.mk

LOCAL_MODULE    := libsmonjni
LOCAL_CFLAGS    := -std=gnu++11 -lm -ldl -static -shared
LOCAL_LDLIBS    := -llog -lstdc++ -lz
LOCAL_SRC_FILES := ../../so_cpp/API.cpp
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../so_cpp/include

APP_ABI := x86
LOCAL_STATIC_LIBRARIES := libjs_static-prebuilt86
LOCAL_SHARED_LIBRARIES := FlashRuntimeExtensions-prebuilt86

include $(BUILD_SHARED_LIBRARY)
