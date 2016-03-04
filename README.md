# fixate-shopify-boilerplate
A boilerplate for Shopify, based on Timber.

# Prepping your site for local dev
To get credentials:

	Log in to Store Admin
	Go to apps
	Select/Create your new app

Setting up your config.yml
	'theme_id' 		Can be left blank
	'access_token'	Password field
	'store'			URL to the front-end of your store
	'refill_rate' 	Rate that tickets are replenished by the Shopify API (per second)
	'bucket_size'	Size of your Access Tokens bucket
	'concurrency'	Number of workers to spawn

# settings_schema.json
Important Note: When this file is updated it will clear all other fields with the same 'type'

# Breadcrumbs
See: http://docs.shopify.com/support/your-website/navigation/creating-a-breadcrumb-navigation

# Dropdown Menu
See: http://docs.shopify.com/manual/your-website/navigation/create-drop-down-menu

The only class used in this boilerplate is .visually-hidden
	This is because it is a commonly used class to hide items.
	If you need this to be changed you can globally search and replace it

All the ajax snippets also have default classes applied to them.

This boilerplate uses https://github.com/fixate/fixate-fabricator as a styleguide.
As such, the grid system is used on some templates/snippets in this boilerplate > [gw, g, g-1/1]

### License

MIT: http://fixate.mit-license.org/
