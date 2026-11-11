IF "%1"=="64" (
    echo "64x Build"
    devtools\bin\vpc.exe +jolt /2022 /win64 /define:PLATFORM_64BITS /define:GAME_SDK2013 /define:GAME_GMOD /mksln jolt.sln
) ELSE (
    echo "32x Build"
    devtools\bin\vpc.exe +jolt /2022 /define:GAME_SDK2013 /define:GAME_GMOD /mksln jolt.sln
)