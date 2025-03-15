# My dotfiles

This directory contains the dotfiles for my system

## Requirements

Ensure you have the following installed on your system

### Git

### Stow

MacOS
```
$ brew install stow
```

## Installation

First, checkout the dotfiles repo in your $HOME directory using git
```
$ git clone git@github.com/EllBoy007/dotfiles.git
$ cd dotfiles
```

then use GNU stow to create symlinks
```
$ stow .
```

## References
    
1. [GNU Stow](https://www.gnu.org/software/stow/)
2. [Stow has forever changed the way I manage my dotfiles](https://www.youtube.com/watch?v=y6XCebnB9gs) via [@dreamsofautonomy](https://www.youtube.com/@dreamsofautonomy) (YouTube)

