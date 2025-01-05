# Bohnanza

## Getting Started

1. Create a repo based on this template
2. While in the repo folder, run `npm i`
3. Edit `.ts` files in the `src` to your hearts content
4. Run `npm run build` to build the lua files to the `build` folder

## Deploying to Tabletop Simulator

To make deploying to TTS simple, I recommend using VSCode and installing the `rolandostar.tabletopsimulator-lua` extension.

Assuming you have those two setup, follow these steps

1. Launch TTS and load the save file you want the scripts to belong to (`TS_Save.json` in the root folder is used for the `src/examples/` scripts)
2. In VSCode use `ctrl + alt + L` to load any scripts from the game into the workspace
3. Run `npm run deploy` to build and copy files to the TTS working directory
4. Use `ctrl + alt + S` to reload the save file in TTS with the newly copied scripts.

### Note on bundling

This repo is set up specifically to work with the `rolandostar.tabletopsimulator-lua` extension, as it uses https://github.com/Benjamin-Dobell/luabundle to bundle output files before sending them to tabletop simulator. **NOTE:** At time of writing, the extension did not work without a workaround which can be found here: https://github.com/KlutzyBubbles/tts-typescript-template/issues/1#issuecomment-2211644958

## Typescript limitations

### Colors

In lua you are sometimes able to pass colors to functions like

```lua
object.TextTool.setFontColor('Blue')
object.TextTool.setFontColor({1, 1, 1})
```

However to support a different typing for `Color.new`, this functionality in typescript has been lost, the solution is to surround them with a `Color` or prefix with `Color.` like

```typescript
object.TextTool.setFontColor(Color.Blue);
object.TextTool.setFontColor(Color.fromString("Blue")); // Alternative to pass string variable
object.TextTool.setFontColor(Color([1, 1, 1]));
```

### Same for vectors

To also support different typings for `Vector.new`, the same thing happens with vectors, you will need to use things like

```typescript
vector.equals(Vector([1, 1, 1]));
```

For vectors this looks to be required for most inputs anyway so it shouldn't be a big problem.

IMO this actually provides more readable code, which is why i kept the change

### Global functions

Because of the way `typescript-to-lua` builds the lua files, functions are local by default.

This means global event functions like the ones found [here](https://api.tabletopsimulator.com/events/) (onLoad etc) will be outputted as local and wont be called by TTS.

To fix this, you can add the function to the `_G` variable, however because of more weirdness with typescript, you have to cast it to any like `(_G as any)`. The following is what it ends up looking like:

```Typescript
(_G as any).onLoad = () => {
    print('This will execute on load')
}

function onLoad() {
    print('This will never execute')
}
```
