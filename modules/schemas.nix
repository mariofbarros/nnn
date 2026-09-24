{ inputs, ... }: {
  # Purely cosmetic: makes `nix flake show`/`nix flake metadata` print
  # human-readable descriptions for standard outputs (nixosConfigurations,
  # packages, etc). No effect on evaluation or builds.
  flake.schemas = inputs.flake-schemas.schemas;
}
