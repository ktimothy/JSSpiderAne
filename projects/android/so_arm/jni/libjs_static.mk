LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE    := libjs_static-prebuilt
LOCAL_SRC_FILES := libjs_staticARM7.a
include $(PREBUILT_STATIC_LIBRARY)
