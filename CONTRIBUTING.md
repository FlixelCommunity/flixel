## How you can help

Any help is welcome, even the smallest one! Start by choosing the way you want to contribute:

* **Fixing bugs**. Browse the [issues list](https://github.com/FlixelCommunity/flixel/issues?page=1&state=open) and pick one labeled as **OPEN**. If the issue is associated with another developers, then someone is already working on that bug.
* **Testing bug fixes and new features**. Every time a bug gets fixed or a new feature is added, we need to test it. Browse the [list of open pull-requests](https://github.com/FlixelCommunity/flixel/pulls), choose one and test if it's ok.
* **Writing a tutorial**. If you know how to use Flixel, help others by teaching them. Check the [writting a tutorial guide](http://deadlink). 

## Fixing bugs

Right now the focus is on releasing a stable version of Flixel `2.56`, **containing bug fixes and performance improvements only**. This release should be reverse-compatible with Flixel `2.55` and able to be dropped in to an existing Flixel game without breaking any existing code.

All issues that must be addressed for the current release are under the [**Flixel v2.56** milestone](https://github.com/FlixelCommunity/flixel/issues?milestone=1&state=open). Any new features or changes that break existing code are saved for the next version of Flixel under the  [**Future release** milestone](https://github.com/FlixelCommunity/flixel/issues?milestone=2&state=open).

### Branches

The code is organized in two branches:

* `FlixelCommunity/master`: the current, stable release; currently at Flixel `v2.55` (Adam Atomic's version).  
* `FlixelCommunity/dev` the developmental version containing all the fixes for the next release.

Only "finished" bug fixes should be merged into the `FlixelCommunity/dev` branch; no "half-finished" code or code that doesn't compile. After all bugs are fixed and all changes are implemented, the `dev` branch will be merged into the `master` branch. From that point on, the `master` will have a stable release and the development activity will start again at the `dev` branch.

### Finding an issue to work on

If you don't already know of a bug and want to find something to work on, you can [browse the existing issues](https://github.com/FlixelCommunity/flixel/issues?page=1&state=open).

Pay attention to the labels:

* **bug**: the issue is a confirmed bug;
* **OPEN**: the issue is active and there is no fix (check a [list of open issues](https://github.com/FlixelCommunity/flixel/issues?labels=OPEN&milestone=1&page=1&state=open)); 
* **has fix**: the issue has a pending pull request that fixes the problem


### Creating a pull request

As usual, be clear in your pull request's description, and follow the coding conventions used by the surrounding Flixel code (e.g. open brackets start on the next line, camel case naming).

To avoid merge conflicts, start your pull requests from the `FlixelCommunity/dev` branch. If you are on a system that supports Bash (usually MAC or Linux), you can use the following [GIT alias](https://git.wiki.kernel.org/index.php/Aliases) to assist:

```
dev = "!git fetch FlixelCommunity && git checkout FlixelCommunity/dev -b "
```

To use the alias, make sure `FlixelCommunity` is added as a remote repository, and run the following command when you want to start working on an issue, which will create a new branch with the specified name:

```
 $ git dev fix-some-issue
```

