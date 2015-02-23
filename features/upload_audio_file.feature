Feature: Upload audio file
	In order to clean my audio files from noise
	As a user
	I want to upload audio files to the app

	Scenario: View submission form
		Given I am on the homepage
		Then I should see "Audio:"
		And I should see "Email:"
		And I should see "Upload!"
	
	Scenario: Validate submission form
		Given I am on the homepage
		* I have selected "testdata/iphone1.wav"
		* I have entered "kim@alliscalm.net"
		And I have agreed to the terms and conditions
		# * The file size is below the maximum permitted size
		# * I am not currently waiting for another audio file report
		# * I have selected at least one test {wind noise, handling noise, distortion}
		Then I should be allowed to submit the form

	Scenario: Upload audio file
		Then I should be shown a confirmation 
		And told to wait for an email containing a link to the audio file report
		And given an estimate of how long it will take to get the audio file report

	Scenario: User is currently waiting for another audio file report
		Given the user is currently waiting for another audio file report
		Then I should see an error message explaining the status of the project