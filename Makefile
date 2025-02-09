ARCHS = arm64

TARGET = iphone:clang:latest:7.0  # Adjust this if targeting a different iOS version

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BlockNet

MyBlockButton_FILES = BlockNet.m  # Your main source file

MyBlockButton_FRAMEWORKS = UIKit  # UIKit is needed for UI elements like UIButton
MyBlockButton_LIBRARIES = objc  # To link the Objective-C runtime

# Specify the property list file
MyBlockButton_PLIST = BlockNet.plist

include $(THEOS)/makefiles/tweak.mk
