# Brighterscript Game Engine

An object oriented game engine for the Roku, written in [Brighterscript](https://github.com/rokucommunity/brighterscript), and available via [ROPM](https://github.com/rokucommunity/ropm).

This project is designed to be used with VScode.

This is forked from [Roku-gameEngine](https://github.com/Romans-I-XVI/Roku-gameEngine) by Austin Sojka, and converted into Brighterscript. This work owes almost everything to this original project!

## Introduction

The purpose of this project is to make it easy to develop games for the Roku in an object oriented fashion. Similar to how you would with an engine such as Phaser, HaxeFlixel, Gamemaker or Unity (minus any visual software that is).

## Cloning and Running Examples

The Brighterscript Game Engine public repository is on [Github](https://github.com/markwpearce/brighterscript-game-engine/)

Clone the project:

```
git clone https://github.com/markwpearce/brighterscript-game-engine.git
```

This project includes various example Roku apps in the `examples` directory. To run them, you will need a Roku and have it set up properly for doing development. See: https://developer.roku.com/en-ca/docs/developer-program/getting-started/developer-setup.md.

To run the examples:

Install dependencies:

```
cd brighterscript-game-engine
npm install
```

You will need to "install" the brighterscript-game-engine in the examples directories. You can do this by running `ropm install` in each example (e.g. ./examples/snake) or by using the handy script:

```
npm run prepare-examples
```

You can manually build the examples from the command line and manually add the zip files to your Roku:

```
npm run build-examples
```

The above command will generate example .zip files like `./examples/asteroids/out/asteroids.zip`

Open the Workspace in VS Code:

```
code brighterscript-game-engine.code-workspace
```

We recommend you install the great [Brightscript Language vscode extension](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript).

Create/edit a `.env` file to specify the details for you target Roku device:

```env
ROKU_USERNAME=<roku development username - default is rokudev>
ROKU_PASSWORD=<roku development password>
ROKU_HOST=<local IP address of the target roku>
```

Then simply run one of the Debug configurations from the Debug tab.

## Installation

_NOTE - Not available yet from ropm!_

Use ropm:

```
ropm install brighterscript-game-engine
```

Suggestion - use a shorter prefix (we use `bge` in the documentation):

```
ropm install bge@npm:brighterscript-game-engine
```

## Documentation

Documentation can be found [here](https://markwpearce.github.io/brighterscript-game-engine)
