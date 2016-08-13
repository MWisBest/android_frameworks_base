LOCAL_PATH:= $(call my-dir)

# This is a list of libraries that need to be included in order to avoid
# bad apps. This prevents a library from having a mismatch when resolving
# new/delete from an app shared library.
# See b/21032018 for more details.
app_process_common_shared_libs := \
    libwilhelm \

include $(CLEAR_VARS)

LOCAL_SRC_FILES:= \
    app_main.cpp

LOCAL_LDFLAGS := -Wl,--version-script,art/sigchainlib/version-script.txt -Wl,--export-dynamic

LOCAL_SHARED_LIBRARIES := \
    libdl \
    libcutils \
    libutils \
    liblog \
    libbinder \
    libandroid_runtime \
    $(app_process_common_shared_libs)

LOCAL_WHOLE_STATIC_LIBRARIES := libsigchain

LOCAL_MODULE:= app_process
LOCAL_MULTILIB := both
LOCAL_MODULE_STEM_32 := app_process32
LOCAL_MODULE_STEM_64 := app_process64

LOCAL_CFLAGS := -Wall -Werror -Wextra -Wunused

ifeq ($(USE_XPOSED_FRAMEWORK),true)
    LOCAL_CFLAGS += -DUSE_XPOSED_FRAMEWORK

    LOCAL_SRC_FILES += \
        xposed.cpp \
        xposed_logcat.cpp \
        xposed_service.cpp \
        xposed_safemode.cpp

    LOCAL_SHARED_LIBRARIES += \
        libselinux

    LOCAL_STRIP_MODULE := keep_symbols
endif

include $(BUILD_EXECUTABLE)

# Create a symlink from app_process to app_process32 or 64
# depending on the target configuration.
include  $(BUILD_SYSTEM)/executable_prefer_symlink.mk


##########################################################
# Xposed Library for ART-specific functions
##########################################################

include $(CLEAR_VARS)

include art/build/Android.common_build.mk
$(eval $(call set-target-local-clang-vars))
$(eval $(call set-target-local-cflags-vars,ndebug))

LOCAL_C_INCLUDES += \
    external/valgrind \
    external/valgrind/include

LOCAL_SRC_FILES += \
    libxposed_common.cpp \
    libxposed_art.cpp

LOCAL_C_INCLUDES += \
    art/runtime \
    external/gtest/include

LOCAL_SHARED_LIBRARIES += \
    libart \
    liblog \
    libcutils \
    libandroidfw \
    libnativehelper

LOCAL_MODULE := libxposed_art
LOCAL_MODULE_TAGS := optional
LOCAL_STRIP_MODULE := keep_symbols
LOCAL_MULTILIB := both

# Always build both architectures (if applicable)
ifeq ($(TARGET_IS_64_BIT),true)
  $(LOCAL_MODULE): $(LOCAL_MODULE)$(TARGET_2ND_ARCH_MODULE_SUFFIX)
endif

include $(BUILD_SHARED_LIBRARY)

