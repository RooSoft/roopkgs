{
  description = "RooSoft's sane defaults for some applications";

  outputs = {...}: {
    nixosModules = {
      home = import ./modules/home;
      system = import ./modules/system;
    };
  };
}
