# Item definition

These are example item definitions for ox_inventory

## Note

- "stack" HAS to be false
- "server.export" HAS to be there
- If you dont use ox_inventory as config option, remove the server part entirly
- You can change: item name, item label and item weight
- The export name has to be the item name, examples below

---

```lua
    ['bulletproof_small'] = {
		label = 'Small vest',
		weight = 1000,
		stack = false,
		close = true,
		server = {
			export = 'zrx_armour.bulletproof_small'
		}
	},

	['bulletproof_medium'] = {
		label = 'Medium vest',
		weight = 1000,
		stack = false,
		close = true,
		server = {
			export = 'zrx_armour.bulletproof_medium'
		}
	},

	['bulletproof_big'] = {
		label = 'Big vest',
		weight = 1000,
		stack = false,
		close = true,
		server = {
			export = 'zrx_armour.bulletproof_big'
		}
	},
```
