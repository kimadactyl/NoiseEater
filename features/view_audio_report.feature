Feature: Audio file report

	After the user has uploaded an audio file, they will be emailed a URL to a report on the file. 

	Scenario: User views audio report

		The report should:

		* Show a visualisation of the whole audio file, with noise regions marked
		* The user can play the audio file in the browser
		* Display a list of markers for all the noise regions
		* Ability to download audio file with noise regions muted, in original or compressed format
		* Ability to download audio file with noise regions removed and concatenated, in original or compressed format

	Scenario: User sends optional feedback about the audio report

		Additionally, the user should be prompted for some optional information.

		* User can indicate which regions are incorrect
		* User can indicate if they are a professional, amateur or something else
		* User is asked why they used the site
		* User is asked what the recording is of
		* User is asked how useful the service was

	Scenario: Audio file is flagged as incorrect
		Given one or more noise regions are marked as incorrect
		Then the database should store the incorrect audio file indefinitely
		And flag the related audio file report as incorect

	Scenario: Track which sections are listened to
		Given the user listens to one or more sections of the audio file
		Then record which sections of the audio file the user listened to

