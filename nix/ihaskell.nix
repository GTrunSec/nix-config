# Until https://github.com/rycee/home-manager/pull/690 is merged

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.ihaskell;
  ihaskellSrc = pkgs.fetchFromGitHub {
    owner = "gibiansky";
    repo = "IHaskell";
    rev = "f17d0a0a688f97f3e06775d8e030f848271d4eb8";
    sha256 = "1l30cps4c09s50dlzf1ivbyrdbj7ys0vz2wbghip7qsddi9yc5ba";
  };
  ihaskellResult = (import (ihaskellSrc + /release.nix) {
    compiler = cfg.compiler;
    packages = cfg.extraPackages;
    pythonPackages = cfg.pythonPackages;
    systemPackages = cfg.systemPackages;
  });

in

{
  meta.maintainers = [ maintainers.srid ];

  options.services.ihaskell = {
    enable = mkEnableOption "IHaskell notebook";

    compiler = mkOption {
      type = types.str;
      default = "ghc864";
      example = literalExample ''
        ghc864
      '';
      description = ''
        The Haskell compiler to use.
      '';
    };

    notebooksPath = mkOption {
      type = types.str;
      example = literalExample ''
        $HOME/ihaskell
      '';
      description = ''
        Directory where IHaskell will store notebooks.
      '';
    };

    extraPackages = mkOption {
      default = self: [];
      example = literalExample ''
        haskellPackages: [
          haskellPackages.wreq
          haskellPackages.lens
        ]
      '';
      description = ''
        Extra packages available to ghc when running ihaskell. The
        value must be a function which receives the attrset defined
        in <varname>haskellPackages</varname> as the sole argument.
      '';
    };

    pythonPackages = mkOption {
      default = self: [];
      example = literalExample ''
        pythonPackages: [
          pythonPackages.numpy
          pythonPackages.z3
        ]
      '';
      description = ''
        Extra Python packages available when running ihaskell.
      '';
    };
    
    systemPackages = mkOption {
      default = self: [];
      example = literalExample ''
        ps: with ps; [
          z3
        ]
      '';
      description = ''
        Extra system packages available when running ihaskell.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.ihaskell = {
      Unit = {
        Description = "IHaskell notebook instance";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.runtimeShell} -c \"mkdir -p ${cfg.notebooksPath}; cd ${cfg.notebooksPath}; ${ihaskellResult}/bin/ihaskell-notebook\"";
        RestartSec = 3;
        Restart = "always";
      };
    };
  };

}
