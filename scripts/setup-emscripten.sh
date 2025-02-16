#!/usr/bin/env bash

if [[ -z "$EMROOT" ]]; then
	EMROOT="$(dirname $(which emcc))"

	if [[ "$EMROOT" == /nix/store/* ]]; then
		EMROOT="$(dirname $(dirname $(which emcc)))/share/emscripten"
	fi
fi

export EMROOT

if [[ -d "$EMROOT/cache" ]]; then
	cp -r "$EMROOT/cache" "$(pwd)/build/xbuild/web/.emcache"
fi

EM_CACHE="$(pwd)/build/xbuild/web/.emcache"
mkdir -p "$EM_CACHE"
chmod u+rwX -R "$EM_CACHE"

export EM_CACHE

echo "EMROOT = $EMROOT"
echo "EM_CACHE = $EM_CACHE"

if [[ ! -f "$EMROOT/cmake/Modules/Platform/Emscripten.cmake" ]]; then
	echo "Emscripten not found! EMROOT='$EMROOT'!"
	emcc -v
	exit 1
fi
