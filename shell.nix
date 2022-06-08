{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
	name="dev-environment";
	buildInputs = [
	    pkgs.splint
	    pkgs.indent
	    pkgs.bundix
		pkgs.binutils
		pkgs.recastnavigation
		pkgs.lz4
		pkgs.libGL
		pkgs.libGLU
		pkgs.glm
		pkgs.freeglut
		pkgs.unshield
		pkgs.libxkbcommon
		pkgs.lsb-release
		pkgs.gdb
		pkgs.automake
		pkgs.gnumake
		pkgs.luajit
		pkgs.ncurses
		pkgs.libxml2
		pkgs.SDL2
		pkgs.bullet
        pkgs.qt6.qt5compat
		pkgs.mygui
		pkgs.openscenegraph
		pkgs.openal
		pkgs.boost
		pkgs.clang
		];
	shellHook = ''
		echo "Begin ..."
	'';
}
