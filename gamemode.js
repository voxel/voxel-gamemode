'use strict';

module.exports = (game, opts) => new GamemodePlugin(game, opts);

module.exports.pluginInfo = {
  loadAfter: ['voxel-mine', 'voxel-fly', 'voxel-registry', 'voxel-harvest', 'voxel-commands', 'voxel-keys']
};

class GamemodePlugin {
  constructor(game, opts) {
    this.game = game;

    this.keys = this.game.plugins.get('voxel-keys');
    if (!this.keys) throw new Error('voxel-gamemode requires voxel-keys plugin');

    this.mode = opts.startMode !== undefined ? opts.startMode : 'survival';
    this.registry = this.game.plugins.get('voxel-registry');
    if (!this.registry) throw new Error('voxel-gamemode requires "voxel-registry" plugin');

    this.enable();
  }

  enable() {
    const commandsPlugin = this.game.plugins.get('voxel-commands');
    if (commandsPlugin) {
      commandsPlugin.registerCommand('creative', this.enterCreative.bind(this), '', 'enters creative mode');
      commandsPlugin.registerCommand('survival', this.enterSurvival.bind(this), '', 'enters survival mode');
    }

    if (this.game.plugins.isEnabled('voxel-fly') && this.mode == 'survival') {
        this.game.plugins.disable('voxel-fly');
    }

    this.keys.registerKey('inventory', 'E');
    this.keys.down.on('inventory', this.onInventory = () => {
      if (this.mode === 'creative' && this.game.plugins.isEnabled('voxel-inventory-creative')) {
        const creative = this.game.plugins.get('voxel-inventory-creative');
        if (creative) creative.open();
      } else {
        const crafting = this.game.plugins.get('voxel-inventory-crafting');
        if (crafting) crafting.open();
      }
    });
  }

  enterCreative() {
    this.mode = 'creative';
    this.game.plugins.enable('voxel-fly');
    if (this.game.plugins.get('voxel-mine')) this.game.plugins.get('voxel-mine').instaMine = true;
    if (this.game.plugins.get('voxel-harvest')) this.game.plugins.get('voxel-harvest').enableToolDamage = false;
    console.log('Entered creative mode');
    if (this.game.plugins.get('voxel-console')) this.game.plugins.get('voxel-console').log('Entered creative mode');
  }

  enterSurvival() {
    this.mode = 'survival';
    this.game.plugins.disable('voxel-fly');
    if (this.game.plugins.get('voxel-mine')) this.game.plugins.get('voxel-mine').instaMine = false;
    if (this.game.plugins.get('voxel-harvest')) this.game.plugins.get('voxel-harvest').enableToolDamage = true;
    console.log('Entered survival mode');
    if (this.game.plugins.get('voxel-console')) this.game.plugins.get('voxel-console').log('Entered survival mode');
  }

  disable() {
    this.keys.down.removeListener('inventory', this.onInventory);
    this.keys.unregisterKey('inventory');
    // TODO: un-registerCommand
  }
}
