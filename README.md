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
You can explicitly set the commit author on every commit using the `--author` option or set it once with `scv config author "Your Name <your@email.com>"`.

You can also set the date (`--date`), set the commit message (`-m` or `--message`) or amend the last commit (`--amend`). If the `-m` flag is not set the default terminal editor will be opened (as in Git).

Example: `scv commit --author "Georgy Angelov <test@test.test>"`

---
`scv history` or `scv log`

Lists all commits, in reverse-chronological order with their **id**, **date**, **author** and **message**.

---
`scv restore <paths>...`

Restores files to the state they were in the `head` commit. `paths` can be files or directories. New files will not be removed, only changed and deleted files are restored.

You can optionally specify the source commit with `-s` or `--source` by giving its object_id, a label name that references it or an object_id and a relative offset (for example `head~3`).

---
`scv branch new <branch_name>` or `scv branch create <branch_name>`

Creates a new branch based on the current branch head.

---
`scv branch delete <branch_name>` or `scv branch remove <branch_name>`

Deletes the specified branch. The commits are not lost, only the label is deleted.

---
`scv branch switch <branch_name>`

Switches the current directory to the specified branch head. It works as follows:
  - Detects the changes that should be made to switch from the current branch to the other
  - If you have modified files that would have to be overrwriten (modified) fails with an error
  - Keeps all of your new or modified files and only overwrites unmodified ones
  - May restore any deleted files that are present in the other branch
  - Switches the current branch to `branch_name` (the following commits will be on branch `branch_name`)

---
`scv config`

Lists all configuration properties and values. The output is similar to the output of the `tree` tool, because the configuration options can be nested:

    level_0
      ├─ level_1_one
      │  ├─ level_2_one: value
      │  └─ level_2_two: true
      └─ level_1_two: value

This configuration is stored in `.scv/config.yml` and is relative only to the current scv repository.

---
`scv config <key>`

Shows the current value of `<key>`. A key of the form `one.two.three` can be used to reference nested properties.

---
`scv config <key> <value>`

Sets the option `key` to `value`. As in the previous command, you can use the `one.two.three` form to reference nested properties. If the key doesn't exist it is created.


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