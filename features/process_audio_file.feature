Feature: Process uploaded audio files

	The server should accept audio file uploads, and process one audio file at a time.

	Scenario: Creating an audio file report
		Given the next audio file in the queue
		Then run the noise detection algorithms the user has selected on the audio file
		* Generate a spectogram
		* Create the cleaned audio file
		* Flag the audio file as processed
		* Email the user with a link to the report
		* Process the next audio file in the queue

	Scenario: New file record is uploaded
		Given a new file record is uploaded
		When no files are currently being processed
		Then process the next file in the queue

	Scenario: Delete old audio files
		Given an audio file was uploaded at least a week ago
		Then delete the audio file

	Scenario: Bandwidth limit is nearing
		Given the web server is near its bandwidth limit
		Then email an administrator with a warning

	Scenario: Bandwidth limit is reached
		Given the web server is at its bandwidth limit
		Then disable the site
		And email an administrator with a warning