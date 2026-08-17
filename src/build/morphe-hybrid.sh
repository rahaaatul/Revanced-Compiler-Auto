#!/bin/bash
source ./src/build/utils.sh

morphe_dl(){
	dl_gh "morphe-patches" "MorpheApp" "prerelease"
	dl_gh "morphe-desktop" "MorpheApp" "latest"
}

rename_apks() {
	local src_prefix=$1 dest_prefix=$2 version=$3 abi_filter=$4
	for f in ./release/${src_prefix}*.apk; do
		[ -f "$f" ] || continue
		local filename=$(basename "$f")
		local abi="all"
		if [[ "$filename" == *"arm64-v8a"* ]]; then
			abi="arm64-v8a"
		elif [[ "$filename" == *"armeabi-v7a"* ]]; then
			abi="armeabi-v7a"
		elif [[ "$filename" == *"x86_64"* ]]; then
			abi="x86_64"
		elif [[ "$filename" == *"x86"* ]]; then
			abi="x86"
		fi
		[[ -n "$abi_filter" && "$abi" != "$abi_filter" ]] && continue
		local new_name="${dest_prefix}_${version}_${abi}.apk"
		mv "$f" "./release/$new_name"
	done
}

get_patch_version() {
	local version=""
	for f in ./*.mpp; do
		[ -f "$f" ] || continue
		if [[ "$f" =~ patches-([0-9]+\.[0-9]+(\.[0-9]+)?)\.mpp ]]; then
			version="${BASH_REMATCH[1]}"
			break
		fi
	done
	echo "$version"
}

write_version() {
	local key=$1 value=$2
	echo "${key}=${value}" >> ./build-versions.txt
}

all() {
	rm -f ./build-versions.txt
	morphe_dl
	local patch_ver
	patch_ver=$(get_patch_version)
	write_version "PATCH_VERSION" "$patch_ver"

	get_patches_key "youtube-morphe"
	get_apk "com.google.android.youtube" "youtube-stable" "apk"
	local yt_stable_ver="$version"
	write_version "YOUTUBE_STABLE" "$yt_stable_ver"
	patch "youtube-stable" "morphe"
	rename_apks "youtube-stable-morphe" "youtube" "$yt_stable_ver" "arm64-v8a"
	rename_apks "youtube-stable-morphe" "youtube" "$yt_stable_ver" "armeabi-v7a"

	get_patches_key "youtube-morphe"
	prefer_version="$youtube_experimental_support"
	get_apk "com.google.android.youtube" "youtube-beta" "bundle"
	local yt_beta_ver="$version"
	write_version "YOUTUBE_BETA" "$yt_beta_ver"
	patch "youtube-beta" "morphe"
	rename_apks "youtube-beta-morphe" "youtube-beta" "$yt_beta_ver" "arm64-v8a"
	rename_apks "youtube-beta-morphe" "youtube-beta" "$yt_beta_ver" "armeabi-v7a"

	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-arm64-v8a" "apk" "arm64-v8a"
	local ytm_stable_ver="$version"
	write_version "YOUTUBE_MUSIC_STABLE" "$ytm_stable_ver"
	patch "youtube-music-stable-arm64-v8a" "morphe"
	rename_apks "youtube-music-stable-arm64-v8a-morphe" "youtube-music" "$ytm_stable_ver" "arm64-v8a"

	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-stable-armeabi-v7a" "apk" "armeabi-v7a"
	patch "youtube-music-stable-armeabi-v7a" "morphe"
	rename_apks "youtube-music-stable-armeabi-v7a-morphe" "youtube-music" "$ytm_stable_ver" "armeabi-v7a"

	get_patches_key "youtube-music-morphe"
	prefer_version="$youtube_music_experimental_support"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-arm64-v8a" "apk" "arm64-v8a"
	local ytm_beta_ver="$version"
	write_version "YOUTUBE_MUSIC_BETA" "$ytm_beta_ver"
	patch "youtube-music-beta-arm64-v8a" "morphe"
	rename_apks "youtube-music-beta-arm64-v8a-morphe" "youtube-music-beta" "$ytm_beta_ver" "arm64-v8a"

	get_patches_key "youtube-music-morphe"
	get_apk "com.google.android.apps.youtube.music" "youtube-music-beta-armeabi-v7a" "apk" "armeabi-v7a"
	patch "youtube-music-beta-armeabi-v7a" "morphe"
	rename_apks "youtube-music-beta-armeabi-v7a-morphe" "youtube-music-beta" "$ytm_beta_ver" "armeabi-v7a"
}

case "$1" in
    all) all ;;
esac