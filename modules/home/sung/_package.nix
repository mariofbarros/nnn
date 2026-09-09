{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  qt6,
  ffmpeg,
  nodejs,
  python3,
}:
let
  # ytmusicapi (catalog browsing) and yt-dlp (stream resolution, needs a JS
  # runtime on PATH -- see nodejs below) aren't linked into the C++ binary;
  # Sung's backend spawns catalog.py as a subprocess and imports them there.
  pythonEnv = python3.withPackages (ps: [
    ps.ytmusicapi
    ps.yt-dlp
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sung";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "yappologistic";
    repo = "Sung";
    rev = "396d7bc6f9a6dbfaee0b0726daf46673acab09c1";
    hash = "sha256-x86otzD1geRKB7iXzj52W8Y5Y1e0o7L5tN/0juyf08M=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qtmultimedia
    qt6.qtsvg
    qt6.qtwayland
    qt6.qtimageformats
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" false)
    (lib.cmakeBool "SUNG_DIAGNOSTICS" false)
  ];

  # catalog.py resolves its own interpreter/helper path relative to the
  # binary by default (../lib/sung/{catalog.py,runtime/bin/python}), but
  # there's no bundled venv here -- point it at the Nix-built pythonEnv
  # instead, and put ffmpeg/node on PATH for the subprocess calls catalog.py
  # and yt-dlp make (ffprobe/ffmpeg for local files, node for yt-dlp's JS
  # challenge solver).
  qtWrapperArgs = [
    "--set SUNG_PYTHON ${pythonEnv}/bin/python"
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg nodejs ]}"
  ];

  meta = {
    description = "Native Material 3 music player for YouTube Music, local files, and Subsonic/Navidrome servers";
    homepage = "https://github.com/yappologistic/Sung";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "sung";
  };
})
