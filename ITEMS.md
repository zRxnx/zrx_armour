# Item definition

These are example item definitions for ox_inventory

## Note

- "stack" HAS to be false
- "server.export" HAS to be there
- If you dont use ox_inventory as config option, remove the server part entirly

---

```lua
    ['bulletproof_small'] = {
		label = 'bulletproof_small',
		weight = 1,
		stack = false,
		close = true,
		server = {
			export = 'zrx_armour.useItem'
		}
	},

	['bulletproof_medium'] = {
		label = 'bulletproof_medium',
		weight = 1,
		stack = false,
		close = true,
		server = {
			export = 'zrx_armour.useItem'
		}
	},

	['bulletproof_big'] = {
		label = 'bulletproof_big',
		weight = 1,
		stack = false,
		close = true,
		server = {
			export = 'zrx_armour.useItem'
		}
	},
```
