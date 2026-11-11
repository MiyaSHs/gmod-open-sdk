# gmod-open-sdk

An open SDK for building native modules against **Garry's Mod's x86-64 beta branch** (the CS:GO-era interface family), assembled
only from public sources and from interoperability reverse engineering (interface layouts, export names) checked against the game.

Goal: build modules like VPhysics-Jolt for the x86-64 beta without the private `gmod-project-sdk`.

- `gmod/src`: Valve's public Source SDK 2013 as minified for GMod by mini-source-sdk (RaphaelIT7, `gmod-changes` branch), under
  Valve's Source 1 SDK License (`LICENSE-VALVE-SOURCE-SDK.txt`, `thirdpartylegalnotices.txt`).
- Headers of the newer interface family come from AlliedModders' public `hl2sdk` (`csgo` branch); see `PROVENANCE.md` for every
  replaced file.
- `cmake/SDKLibraries.cmake`: builds tier1, mathlib and tier2 (MSVC, x64, /MT Release) from the SDK's own VPC file lists and exposes
  `SourceSDK::tier1`, `SourceSDK::mathlib`, `SourceSDK::tier2`, `SourceSDK::tier2_interfaces`, `SourceSDK::headers`.
- `gmod/src/lib/beta/x64/*.def`: export names of the beta branch's `tier0.dll` / `vstdlib.dll`; the import libraries are generated
  at build time. No game binary is stored in this repository.

No leaked Valve or Facepunch source code is used. Distributed free of charge, as the Source 1 SDK License requires. This project's own
files are MIT-0; see `LICENSE.md`.

## Building VPhysics-Jolt with it

```powershell
# Visual Studio 2022 (or its Build Tools) with the C++ workload; from a GMod-Jolt-Physics checkout with submodules:
cmake -S vphysics_jolt -B build-avx2 -G "Visual Studio 17 2022" -A x64 `
  "-DVOLT_GMOD_SDK=<path to this repo>/gmod/src" -DSOURCE_SDK_PROFILE=gmod-beta -DVOLT_CPU_VARIANT=avx2
cmake --build build-avx2 --config Release --target vphysics_jolt_avx2 vphysics --parallel
```

The tier1 / mathlib / tier2 static libraries and the tier0 / vstdlib import libraries are built automatically by the SDK's CMake.

## Status (2026-11-11)

- VPhysics-Jolt v1.1.1 (schweiziske/GMod-Jolt-Physics) builds unmodified against this SDK with its `gmod-beta` profile
  (`-DVOLT_GMOD_SDK=<this repo>/gmod/src -DSOURCE_SDK_PROFILE=gmod-beta`, Visual Studio 2022, x64), and the resulting
  `vphysics_jolt_avx2.dll` runs a 12-a-side NPC battle on the x86-64 beta like the official build (0 errors, same frame rate).
