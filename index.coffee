
ItemPile = require 'itempile'
Inventory = require 'inventory'

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
    carry = @game.plugins?.get('voxel-carry')
    if carry
      @survivalInventory = new Inventory(carry.inventory.width, carry.inventory.height)
      @creativeInventory = new Inventory(carry.inventory.width, carry.inventory.height)

      registry = @game.plugins?.get('voxel-registry')
      if registry?
        # one of everything, please..
        # TODO: better organization, and will checking here get all registered items everywhere?
        i = 0
        for props in registry.blockProps
          if props.name?
            @creativeInventory.set(i, (new ItemPile(props.name, Infinity))) 
            i += 1


    @game.buttons.down.on 'gamemode', @onDown = () =>
      # TODO: add gamemode event? for plugins to handle instead of us

      playerInventory = @game.plugins.get('voxel-carry')?.inventory
      if @mode == 'survival'
        @mode = 'creative';
        @game.plugins.enable('voxel-fly');
        @game.plugins.get('voxel-mine')?.instaMine = true
    
        playerInventory?.transferTo(@survivalInventory) if @survivalInventory?
        @creativeInventory?.transferTo(playerInventory) if playerInventory?

        console.log 'creative mode'
      else
        @mode = 'survival'
        @game.plugins.disable 'voxel-fly'
        @game.plugins.get('voxel-mine')?.instaMine = false

        playerInventory?.transferTo(@creativeInventory) if @creativeInventory?
        @survivalInventory?.transferTo(playerInventory) if playerInventory?

        console.log 'survival mode'

  disable: () ->
    @game.buttons.down.removeListener 'gamemode', this.onDown

