{ fetchFromGitHub, trivialBuild }:

trivialBuild rec {
  pname = "straight.el";
  ename = pname;
  patches = [ ./nogit.patch ];
  src = fetchFromGitHub {
    owner = "raxod502";
    repo = "straight.el";
    rev = "e20a44c4ac5c04896aecd43a5fdd12c67527c69e";
    sha256 = "sha256-kNBdlEfG+RAE+iA8OKOhqmPiZEjjV24r6ziE9Y5ZdVg=";
  };
}
