{
  description = "Environment for pytorch";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    poetry2nix,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          #config.cudaSupport = true;
          #config.allowUnfree = true;
          overlays = [
            poetry2nix.overlays.default
          ];
        };
        p2n-overrides = build-extras:
          pkgs.poetry2nix.defaultPoetryOverrides.extend (self: super:
            builtins.mapAttrs (
              package: pbuild-extras:
                (builtins.getAttr package super).overridePythonAttrs (
                  old:
                    pbuild-extras
                    // {
                      nativeBuildInputs =
                        (old.nativeBuildInputs or [])
                        ++ (pbuild-extras.nativeBuildInputs or []);
                      buildInputs =
                        (old.buildInputs or [])
                        ++ builtins.map (pkg:
                          if builtins.isString pkg
                          then builtins.getAttr pkg super
                          else pkg)
                        (pbuild-extras.buildInputs or []);
                      propagatedBuildInputs =
                        (old.buildInputs or [])
                        ++ builtins.map (pkg:
                          if builtins.isString pkg
                          then builtins.getAttr pkg super
                          else pkg)
                        (pbuild-extras.propagatedBuildInputs or []);
                    }
                )
            )
            build-extras);
        pythonP2NEnv = pkgs.poetry2nix.mkPoetryEnv {
          projectDir = ./pyenvs/default;
          preferWheels = true;
          #overrides = p2n-overrides {
            #djangorestframework-queryfields.buildInputs = ["setuptools"];
            #djangorestframework-xml.buildInputs = ["setuptools"];
            #djangorestframework-yaml.buildInputs = ["setuptools"];
            #djangorestframework-filters.buildInputs = ["setuptools"];
            #xyzservices.buildInputs = ["setuptools"];
            #alignn.buildInputs = ["setuptools"];
            #kt-legacy.buildInputs = ["setuptools"];
            #pycifrw.buildInputs = ["setuptools"];
            #namex.buildInputs = ["setuptools"];
            #keras-tuner.buildInputs = ["setuptools"];
            #matminer.buildInputs = ["setuptools"];
            #pyxtal.buildInputs = ["setuptools"];
            #kgcnn.buildInputs = ["setuptools"];
            #aflow.buildInputs = ["setuptools" "pytest-runner"];
            #m3gnet = {
            #  buildInputs = ["setuptools"];
            #  propagatedBuildInputs = ["numpy"];
            #};
            #ml-dtypes = {
            #  buildInputs = ["pybind11"];
            #  propagatedBuildInputs = ["numpy"];
            #};
            #astropy = {
            #  buildInputs = ["astropy-extension-helpers"];
            #  propagatedBuildInputs = ["numpy"];
            #};
            #dnspython.buildInputs = ["hatchling"];
            #sphinxcontrib-jquery.buildInputs = ["sphinx"];
            #nvidia-cusparse-cu12.propagatedBuildInputs = with pkgs.cudaPackages; [
            #  libnvjitlink
            #  libcusparse
            #  libcublas
            #];
            #nvidia-cusolver-cu12.propagatedBuildInputs = with pkgs.cudaPackages; [
            #  libnvjitlink
            #  libcusparse
            #  libcublas
            #];
            #xgboost = {
            #  nativeBuildInputs = [pkgs.cmake];
            #  dontUseCmakeConfigure = true;
            #};
            #optree = {
            #  buildInputs = ["setuptools" "pybind11"];
            #  nativeBuildInputs = [pkgs.cmake];
            #  dontUseCmakeConfigure = true;
            #};
            #spglib = {
            #  buildInputs = ["scikit-build-core"];
            #  propagatedBuildInputs = ["numpy"];
            #  nativeBuildInputs = [pkgs.cmake];
            #  dontUseCmakeConfigure = true;
            #};
            #jarvis-tools = {
            #  buildInputs = ["setuptools"];
            #  postPatch = ''
            #    substituteInPlace setup.py --replace "with open(os.path.join(base_dir, \"README.md\")) as f:" ""
            #    substituteInPlace setup.py --replace "    long_d = f.read()" "long_d=\"JARIVS-tools\""
            #  '';
            #};
            #torch-cluster = {
            #  buildInputs = ["setuptools"];
            #  propagatedBuildInputs = ["torch"];
            #  nativeBuildInputs = [pkgs.which];
            #};
            #torch-scatter = {
            #  buildInputs = ["setuptools"];
            #  propagatedBuildInputs = ["torch"];
            #};
            #torch-sparse = {
            #  buildInputs = ["setuptools"];
            #  propagatedBuildInputs = ["torch"];
            #  nativeBuildInputs = [pkgs.which];
            #};
            #torch-geometric = {
            #  buildInputs = ["setuptools"];
            #  propagatedBuildInputs = ["torch"];
            #  nativeBuildInputs = [pkgs.which];
            #};
            #tensorflow-addons.propagatedBuildInputs = [pkgs.libtensorflow];
            #pyshtools = let
            #  cfg = pkgs.writeTextFile {
            #    name = "site.cfg";
            #    text =
            #      pkgs.lib.generators.toINI
            #      {}
            #      {
            #        "fftw" = {
            #          include_dirs = "${pkgs.fftw.dev}/include";
            #          library_dirs = "${pkgs.fftw}/lib";
            #        };
            #      };
            #  };
            #in {
            #  preBuild = ''
            #    ln -s ${cfg} site.cfg
            #  '';
            #  buildInputs = ["setuptools"];
            #  propagatedBuildInputs = ["numpy" pkgs.fftw];
            #  nativeBuildInputs = with pkgs; [gfortran];
            #  postPatch = ''
            #    substituteInPlace setup.py --replace "import sysconfig" "import pkg_resources, sysconfig"
            #    substituteInPlace setup.py --replace "parse_version = setuptools.version.pkg_resources.packaging.version.parse" "parse_version = pkg_resources.packaging.version.parse"
            #  '';
            #};
          #};
        };
      in {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            pythonP2NEnv # compiles many things, needs overrides
          ];
        };
      }
    );
}
