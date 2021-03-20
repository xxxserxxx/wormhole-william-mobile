PLATFORM_JAR=$(ANDROID_HOME)/platforms/android-30/android.jar
AAR=android/libs/wormhole-william.aar
BUILDTOOLS=$(ANDROID_SDK_ROOT)/build-tools/30.0.3
ZIPALIGN=$(BUILDTOOLS)/zipalign
APKSIGNER=$(BUILDTOOLS)/apksigner
SIGNKEY=$(HOME)/.android-release/wormhole-william-release.keystore

wormhole-william.debug.apk: $(AAR)
	(cd android && ./gradlew assembleDebug)
	mv android/build/outputs/apk/debug/android-debug.apk $@

wormhole-william.release.apk: $(AAR)
	(cd android && ./gradlew assembleRelease)
	$(ZIPALIGN) -v -p 4 android/build/outputs/apk/release/android-release-unsigned.apk wormhole-william-unsigned-aligned.apk
	$(APKSIGNER) sign --ks $(SIGNKEY) --out $@ wormhole-william-unsigned-aligned.apk
	rm wormhole-william-unsigned-aligned.apk

$(AAR): $(shell find . -name '*.go' -o -name '*.java' -type f) jgo.jar
	mkdir -p $(@D)
	go run gioui.org/cmd/gogio -buildmode archive -target android -appid io.sanford.wormhole_william -o $@ .

jgo.jar: $(wildcard jgo/*.java)
	mkdir -p classes
	javac -cp "$(PLATFORM_JAR)" -d classes $^
	jar cf $@ -C classes .
	rm -rf classes
