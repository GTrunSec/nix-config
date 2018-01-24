{ config, pkgs, ...}:

{
  services.emacs = {
    enable = true;
    defaultEditor = true;
    package = with pkgs; (emacsWithPackages (with emacsPackagesNg; [
      ace-window
      avy
      beacon         # ; highlight my cursor when scrolling
      counsel
      elm-mode
      evil
      github-theme
      haskell-mode
      ivy
      ivy-hydra
      leuven-theme
      lispy
      magit          # ; Integrate git <C-x g>
      markdown-mode
      material-theme
      nix-mode
      org
      pdf-tools
      python-mode
      swiper
      undo-tree      # ; <C-x u> to show the undo tree
      worf
      yaml-mode
      zenburn-theme
      # zerodark-theme -- fails due to checksum mismatch on font-lock+.el
    ]));
  };
}