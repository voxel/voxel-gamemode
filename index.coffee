
ItemPile = require 'ItemPile'

module.exports = (game, opts) ->
  return new Gamemode(game, opts);

module.exports.pluginInfo =
  loadAfter: ['voxel-mine', 'voxel-carry', 'voxel-fly', 'voxel-registry']

class Gamemode
  constructor: (@game, opts) ->
    if not @game.buttons.down?
        throw 'voxel-gamemode requires game.buttons as kb-bindings (vs kb-controls), cannot add down event listener'

    @mode = opts.startMode ? 'survival'
    @registry = @game.plugins?.get('voxel-registry') ? throw 'voxel-gamemode requires "voxel-registry" plugin'

    @enable();

  enable: () ->
    # one of everything, please..
    creativeInventoryArray = []
    registry = @game.plugins?.get('voxel-registry')
    if registry?
      for props in registry.blockProps
        creativeInventoryArray.push(new ItemPile(props.name, Infinity)) if props.name?

    survivalInventoryArray = []

    @game.buttons.down.on 'gamemode', @onDown = () =>
      # TODO: add gamemode event? for plugins to handle instead of us

      inventoryHotbar = @game.plugins.get('voxel-inventory-hotbar')  # TODO: this should change voxel-carry inventory, not the hotbar directlyhhh
      if @mode == 'survival'
        @mode = 'creative';
        @game.plugins.enable('voxel-fly');
        @game.plugins.get('voxel-mine')?.instaMine = true
        @survivalInventoryArray = inventoryHotbar.inventory.array
        inventoryHotbar?.inventory.array = creativeInventoryArray
        inventoryHotbar?.refresh()
        console.log 'creative mode'
      else
        @mode = 'survival'
        @game.plugins.disable 'voxel-fly'
        @game.plugins.get('voxel-mine')?.instaMine = false
        inventoryHotbar?.inventory.array = survivalInventoryArray
        inventoryHotbar?.refresh()
        console.log 'survival mode'

  disable: () ->
    @game.buttons.down.removeListener 'gamemode', this.onDown

