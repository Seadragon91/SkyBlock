g_PluginInfo =
{
	Name = "SkyBlock",
	Date = "2015.10.25",
	Description =
	[[


	]],

	AdditionalInfo =
	{
		{
			Title = "Configuration",
			Contents =
			[[
				In the file Config.ini admins can specify the world name, the distance between
				the islands. Adding a schematic file name for island and spawn platform.

				Admins can change the the default language for the plugin. Also it's possible to
				add other language files and players can select the language they want.
			]]
		}
	},

	Commands =
	{
		["/skyblock"] =
		{
			Alias = "/sb",
			Subcommands =
			{
				help =
				{
					HelpString = "Shows all the commands from the plugin",
					Permission = "skyblock.help",
					Handler = HandleSkyBlockHelp,
				},

				join =
				{
					HelpString = "Join the skyblock world.",
					Permission = "skyblock.join",
					Handler = HandleSkyBlockJoin,
				},

				play =
				{
					HelpString = "Creates the island if necessary and teleport the player to the island",
					Permission = "skyblock.play",
					Handler = HandleSkyBlockPlay,
				},

				recreate =
				{
					HelpString = "Recreates the spawn platform",
					Permission = "skyblock.admin.recreate",
					Handler = HandleSkyBlockRecreate,
				},

				language =
				{
					HelpString = "Recreates the spawn platform",
					Permission = "skyblock.language",
					Handler = HandleSkyBlockLanguage,
					ParameterCombinations =
					{
						{
							Params = "",
							Help = "List all available language files",
						},
						{
							Params = "<language>",
							Help = "Change the language to the given language",
						}
					},
				},
			},
		},

		["/challenges"] =
		{
			Subcommands =
			{
				list =
				{
					HelpString = "Shows info to a challenge",
					Permission = "challenges.list",
					Handler = HandleChallengesList,
				},

				info =
				{
					HelpString = "Shows info to a challenge",
					Permission = "challenges.info",
					Handler = HandleChallengesInfo,
					ParameterCombinations =
					{
						{
							Params = "<challenge name>",
						},
					},
				},

				complete =
				{
					HelpString = "Completes the challenge",
					Permission = "challenges.complete",
					Handler = HandleChallengesComplete,
					ParameterCombinations =
					{
						{
							Params = "<challenge name>",
						},
					},
				},

				check =
				{
					HelpString = "Check the items of an challenge",
					Permission = "challenges.admin.check",
					Handler = HandleChallengesCheck,
					ParameterCombinations =
					{
						{
							Params = "<challenge name> <req>",
							Help = "Get the required items for the challenge",
						},
						{
							Params = "<challenge name> <req> <rpt>",
							Help = "Get the required items for the repeatable challenge",
						},
						{
							Params = "<challenge name> <rew>",
							Help = "Get the reward items for the challenge",
						},
						{
							Params = "<challenge name> <rew> <rpt>",
							Help = "Get the reward items for repeatable the challenge",
						},
					},
				},
			}
		},

		["/island"] =
		{
			Subcommands =
			{
				home =
				{
					HelpString = "Teleports to the island",
					Permission = "island.home",
					Handler = HandleIslandHome,
					ParameterCombinations =
					{
						{
							Params = "<set>",
						},
					},
				},

				obsidian =
				{
					HelpString = "Change the obsidian back to lava",
					Permission = "island.obsidian",
					Handler = HandleIslandObsidian,
				},

				add =
				{
					HelpString = "Add a player to the islands friend list",
					Permission = "island.add",
					Handler = HandleIslandAdd,
					ParameterCombinations =
					{
						{
							Params = "<player name>",
						},
					},
				},

				remove =
				{
					HelpString = "Remove a player from the islands friend list",
					Permission = "island.add",
					Handler = HandleIslandRemove,
					ParameterCombinations =
					{
						{
							Params = "<player name>",
						},
					},
				},

				join =
				{
					HelpString = "Teleport to a friends island",
					Permission = "island.join",
					Handler = HandleIslandJoin,
					ParameterCombinations =
					{
						{
							Params = "<player name>",
						},
					},
				},

				list =
				{
					HelpString = "List friends from island and islands who player can access",
					Permission = "island.list",
					Handler = HandleIslandList,
					ParameterCombinations =
					{
						{
							Params = "<player name>",
						},
					},
				},

				restart =
				{
					HelpString = "Restart the island",
					Permission = "island.restart",
					Handler = HandleIslandRestart,
				},
			},
		},
	},
}
