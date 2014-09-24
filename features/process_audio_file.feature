Feature: Process uploaded audio files

	The server should accept audio file uploads, and process one audio file at a time.

	Scenario: Creating an audio file report
		Given the next audio file in the queue
		Then run the noise detection algorithms the user has selected on the audio file
		And save the results to the database
		Then email the user with a link to the report
		And process the next audio file in the queue

	Scenario: New audio file is uploaded
		Given a new audio record is uploaded
		Then add the audio file and user information into the queue
		And process it immediately if there are no other audio files in the queue

	Scenario: Delete old audio files
		Given an audio file was uploaded at least a week ago
		And the audio file has not been flagged
		Then delete the audio file

	Scenario: Bandwidth limit is reached
		Given the web server is at bandwidth limit
		Then disable the site
		And email an administrator