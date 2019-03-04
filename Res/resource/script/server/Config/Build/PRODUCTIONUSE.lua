PRODUCTIONUSE=
{
--Start--

	 SOURCE_3010004 = {
		PRE=
		{
			{7,9},
		},

		USE=
		{
			{1,1010064,1},
		},

		BUILDID=2,
		BASERATE = 2,
		PRIORITY = 3,
	 },


	 SOURCE_1010063 = {
		PRE=
		{
			{7,3},
		},

		USE=
		{
			{0},
		},

		BUILDID=2,
		BASERATE = 1,
		PRIORITY = 1,
	 },


	 SOURCE_1010064 = {
		PRE=
		{
			{7,3},
		},

		USE=
		{
			{1,1010063,2},
		},

		BUILDID=2,
		BASERATE = 1,
		PRIORITY = 2,
	 },


	 SOURCE_1010005 = {
		PRE=
		{
			{7,8},
		},

		USE=
		{
			{1,1010064,5},
		},

		BUILDID=2,
		BASERATE = 1,
		PRIORITY = 4,
	 },


	 SOURCE_1010001 = {
		PRE=
		{
			{7,8},
		},

		USE=
		{
			{1,1010064,5},
		},

		BUILDID=2,
		BASERATE = 1,
		PRIORITY = 5,
	 },


	 SOURCE_1010006 = {
		PRE=
		{
			{7,10},
		},

		USE=
		{
			{1,1010005,5},
			{1,1010063,5},
		},

		BUILDID=2,
		BASERATE = 1,
		PRIORITY = 6,
	 },


	 SOURCE_1010002 = {
		PRE=
		{
			{7,10},
		},

		USE=
		{
			{1,1010001,5},
			{1,1010063,5},
		},

		BUILDID=2,
		BASERATE = 1,
		PRIORITY = 7,
	 },

}--End
