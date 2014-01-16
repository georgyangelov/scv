SCV
===
The SCV is a tool that every terran player absolutely must use to have a stable and well-organized (code)base.

Seriously though...
===================
This project was inspired by [the Git lecture](http://fmi.ruby.bg/lectures/15-git#1) I made for [this year's Ruby course](http://fmi.ruby.bg) at my university. It is also my course project.

The name SCV has two different meanings:

1. It is `VCS` (Version Control System) in reverse
2. It is the name of a StarCraft unit (a worker) which can gather resources and can also build and repair stuff.

Overview
========
The goal is to create a working (you don't say) version control system in Ruby.

The project itself is split into two parts: [**VCSToolkit**](https://github.com/stormbreakerbg/vcs-toolkit) and **SCV**.
**VCSToolkit** is a Ruby gem that is supposed to provide the platform and common tools, upon which a VCS tool can be built. This is where most of the common operations for such a tool are (being) implemented. **SCV** only implements some of **VCSToolkit**'s interfaces, extends (minimally) its classes and provides a user-friendly command-line interface to its methods.

Features
========
*Note: The examples below use the form `scv <command>`, but if you want to test it right now, follow the 3 steps in the **Try it!** section and use `./run_scv <command>`.*

Currently implemented features:

---
`scv init`

Initializes an empty repository.

Actually creates a `.scv` directory in the current folder and the default `head` label (pointer to a `nil` commit).

---
`scv status`

Shows the list of created, modified and deleted files since the last commit.

---
`scv diff`

Shows the actual differences between the files in the last commit and the working directory.

---
`scv commit`

Commits the current state of the working directory. All changed, new and deleted files are commited.
For now, you should explicitly set the commit author on every commit using the `--author` option.

You can also set the date (`--date`), set the commit message (`-m` or `--message`) or amend the last commit (`--amend`). If the `-m` flag is not set the default terminal editor will be opened (as in Git).

Example: `scv commit --author "Georgy Angelov <test@test.test>"`

---
`scv history` or `scv log`

Lists all commits, in reverse-chronological order with their **id**, **date**, **author** and **message**.


Try it!
=======
Since there are a lot of features currently missing, SCV is not yet available on RubyGems.

1. Clone this repository
2. `bundle install`
3. `./run_scv help`

.scv structure
================

	.scv/

      objects/
        59/
          59873e99cef61a60b3826e1cbb9d4b089ae78c2b.json
          ...
        ...

      refs/
        HEAD.json
        master.json
        ...

      blobs/
        59/
          59873e99cef61a60b3826e1cbb9d4b089ae78c2b
          ...
        ...

Each object in `.scv/objects/` is stored in a directory with a name of the first two symbols of the object id.

The blob objects follow the same naming scheme as the regular ones, but they are just a copy of the original user files (not in `json` format).

The refs are named objects (object.named? == true) and can be enumerated. Currently the only named objects are labels which are used as pointers to unnamed ones.

Other
=====
Contributions are most welcome, but I doubt there will be any :)

If you are interested in learning more about this you can ask me on Twitter [@stormbreakerbg](https://twitter.com/stormbreakerbg).

![SCV](http://static3.wikia.nocookie.net/__cb20080906211455/starcraft/images/2/24/SCV_SC2_Cncpt1.jpg)