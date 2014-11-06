LOCAL_PATH:= $(call my-dir)

# build ARMv7 version
include $(CLEAR_VARS)
include $(LOCAL_PATH)/FlashRuntimeExtensions.mk
include $(LOCAL_PATH)/libjs_static.mk

LOCAL_MODULE    := libsmonjni
LOCAL_CFLAGS    := -std=gnu++11 -lm -ldl -static -shared
LOCAL_LDLIBS    := -llog -lstdc++ -lz
LOCAL_SRC_FILES := ../../so_cpp/APIU.cpp
LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../so_cpp/include

APP_ABI := armeabi-v7a
LOCAL_STATIC_LIBRARIES := libjs_static-prebuilt
LOCAL_SHARED_LIBRARIES := FlashRuntimeExtensions-prebuilt

include $(BUILD_SHARED_LIBRARY)
