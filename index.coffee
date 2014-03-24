
ItemPile = require 'itempile'
Inventory = require 'inventory'

module.exports = (game, opts) ->
  return new Gamemode(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-mine', 'voxel-fly', 'voxel-registry', 'voxel-harvest']

class Gamemode
  constructor: (@game, opts) ->
    return if not @game.isClient # TODO

    if not @game.buttons.down?
        throw new Error('voxel-gamemode requires game.buttons as kb-bindings (vs kb-controls), cannot add down event listener')

    @mode = opts.startMode ? 'survival'
    @registry = @game.plugins?.get('voxel-registry') ? throw new Error('voxel-gamemode requires "voxel-registry" plugin')

    @enable()

  enable: () ->
    if @game.plugins?.isEnabled('voxel-fly') and @mode == 'survival'
        @game.plugins.disable('voxel-fly')

    @game.buttons.down.on 'gamemode', @onDown = () =>
      # TODO: add gamemode event? for plugins to handle instead of us

      if @mode == 'survival'
        @mode = 'creative'
        @game.plugins.enable('voxel-fly')
        @game.plugins.get('voxel-mine')?.instaMine = true
        @game.plugins.get('voxel-harvest')?.enableToolDamage = false

        console.log 'creative mode'
      else
        @mode = 'survival'
        @game.plugins.disable 'voxel-fly'
        @game.plugins.get('voxel-mine')?.instaMine = false
        @game.plugins.get('voxel-harvest')?.enableToolDamage = true

        console.log 'survival mode'

    @game.buttons.down.on 'inventory', @onInventory = () =>
      if @mode == 'creative' and @game.plugins.isEnabled('voxel-inventory-creative')
        @game.plugins.get('voxel-inventory-creative')?.open()
      else
        @game.plugins.get('voxel-inventory-crafting')?.open()


  disable: () ->
    @game.buttons.down.removeListener 'gamemode', @onDown
    @game.buttons.down.removeListener 'inventory', @onInventory


