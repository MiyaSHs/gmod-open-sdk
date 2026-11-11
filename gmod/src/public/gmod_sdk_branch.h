// gmod-open-sdk: selects Garry's Mod's x86-64 beta interface family (the CS:GO-era ABI). GMOD_SDK_PUBLIC stays undefined, so
// consumers that follow the gmod-project-sdk convention (e.g. VPhysics-Jolt's compat/branch_overrides.h) define GAME_GMOD_64X.
#pragma once
#define GMOD_OPEN_SDK 1
#define GMOD_SDK_BRANCH_X86_64 1
