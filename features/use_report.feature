Feature: Executive reports for project administrators

	Project admins need various reports about the website usage.

	Scenario: View audio upload report
		Given an administrator accesses the audio upload report
		Then show a spreadsheet of all the audio uploads

	Scenario: View demographics report
		* Google Analytics should be installed

	Scenario: View flagged errors
		Given there are one or more errors
		Then show a table of files and what times they are wrong
		And give the option to download the files
		And give the option to then delete the files