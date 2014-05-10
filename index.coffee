
ItemPile = require 'itempile'
Inventory = require 'inventory'

module.exports = (game, opts) ->
  return new Gamemode(game, opts)

module.exports.pluginInfo =
  loadAfter: ['voxel-mine', 'voxel-fly', 'voxel-registry', 'voxel-harvest', 'voxel-commands', 'voxel-keys']

class Gamemode
  constructor: (@game, opts) ->
    return if not @game.isClient # TODO

    @keys = @game.plugins.get('voxel-keys') ? throw new Error('voxel-gamemode requires voxel-keys plugin')

    @mode = opts.startMode ? 'survival'
    @registry = @game.plugins?.get('voxel-registry') ? throw new Error('voxel-gamemode requires "voxel-registry" plugin')

    @enable()

  enable: () ->
    @game.plugins?.get('voxel-commands')?.registerCommand 'creative', @enterCreative.bind(@), '', 'enters creative mode'
    @game.plugins?.get('voxel-commands')?.registerCommand 'survival', @enterSurvival.bind(@), '', 'enters survival mode'

    if @game.plugins?.isEnabled('voxel-fly') and @mode == 'survival'
        @game.plugins.disable('voxel-fly')

    @keys.registerKey 'inventory', 'E'
    @keys.down.on 'inventory', @onInventory = () =>
      if @mode == 'creative' and @game.plugins.isEnabled('voxel-inventory-creative')
        @game.plugins.get('voxel-inventory-creative')?.open()
      else
        @game.plugins.get('voxel-inventory-crafting')?.open()

  enterCreative: () ->
    @mode = 'creative'
    @game.plugins.enable('voxel-fly')
    @game.plugins.get('voxel-mine')?.instaMine = true
    @game.plugins.get('voxel-harvest')?.enableToolDamage = false
    console.log 'Entered creative mode'
    @game.plugins?.get('voxel-console')?.log?('Entered creative mode')

  enterSurvival: () ->
    @mode = 'survival'
    @game.plugins.disable 'voxel-fly'
    @game.plugins.get('voxel-mine')?.instaMine = false
    @game.plugins.get('voxel-harvest')?.enableToolDamage = true
    console.log 'Entered survival mode'
    @game.plugins?.get('voxel-console')?.log?('Entered survival mode')

  disable: () ->
    @keys.down.removeListener 'inventory', @onInventory
    @keys.unregisterKey 'inventory'
    # TODO: un-registerCommand


