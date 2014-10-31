LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE    := libjs_static-prebuilt86
LOCAL_SRC_FILES := libjs_static.a
include $(PREBUILT_STATIC_LIBRARY)
