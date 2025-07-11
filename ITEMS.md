# Item definition

These are example item definitions for ox_inventory

## Note

- "stack" HAS to be false
- "server.export" HAS to be there
- You can change: item name, item label and item weight

---

```lua
    ['bulletproof_small'] = {
		label = 'Small vest',
		weight = 1000,
		stack = false,
		close = true,
		server = {
			export = 'zrx_armour.useItem'
		}
	},

	['bulletproof_medium'] = {
		label = 'Medium vest',
		weight = 1000,
		stack = false,
		close = true,
		server = {
			export = 'zrx_armour.useItem'
		}
	},

	['bulletproof_big'] = {
		label = 'Big vest',
		weight = 1000,
		stack = false,
		close = true,
		server = {
			export = 'zrx_armour.useItem'
		}
	},
```
