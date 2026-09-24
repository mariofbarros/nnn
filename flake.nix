{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning -- only used by modules/features/disko
    # (see that file), which no current host imports. Kept for the next
    # fresh install/reinstall, not applied to nix-btw/nixbook as they are.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Adds human-readable descriptions to `nix flake show`/`nix flake
    # metadata` output (see modules/schemas.nix). No functional effect.
    flake-schemas.url = "github:DeterminateSystems/flake-schemas";

    # Companion CLI for late.sh (packages.${system}.late) -- local audio
    # playback synced to the public `ssh late.sh` session.
    late-sh = {
      url = "github:mpiorowski/late-sh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}